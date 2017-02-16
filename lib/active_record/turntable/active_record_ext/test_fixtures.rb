#
# force TestFixtures to begin transaction with all shards.
#
require "active_record/fixtures"

module ActiveRecord::Turntable
  module ActiveRecordExt
    module TestFixtures
      # rubocop:disable Style/ClassVars, Style/RedundantException
      def setup_fixtures(config = ActiveRecord::Base)
        if pre_loaded_fixtures && !use_transactional_fixtures
          raise RuntimeError, "pre_loaded_fixtures requires use_transactional_fixtures"
        end

        @fixture_cache = {}
        @fixture_connections = []
        @@already_loaded_fixtures ||= {}

        # Load fixtures once and begin transaction.
        if run_in_transaction?
          if @@already_loaded_fixtures[self.class]
            @loaded_fixtures = @@already_loaded_fixtures[self.class]
          else
            @loaded_fixtures = load_fixtures(config)
            @@already_loaded_fixtures[self.class] = @loaded_fixtures
          end
          ActiveRecord::Base.force_connect_all_shards!
          @fixture_connections = enlist_fixture_connections
          @fixture_connections.each do |connection|
            connection.begin_transaction joinable: false
          end
          # Load fixtures for every test.
        else
          ActiveRecord::FixtureSet.reset_cache
          @@already_loaded_fixtures[self.class] = nil
          @loaded_fixtures = load_fixtures(config)
        end

        # Instantiate fixtures for every test if requested.
        instantiate_fixtures if use_instantiated_fixtures
      end
      # rubocop:enable Style/ClassVars, Style/RedundantException

      def enlist_fixture_connections
        ActiveRecord::Base.connection_handler.connection_pool_list.map(&:connection) +
          ActiveRecord::Base.turntable_connections.values.map(&:connection)
      end
    end
  end
end
