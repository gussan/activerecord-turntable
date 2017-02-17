module ActiveRecord::Turntable
  module ActiveRecordExt
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :AbstractAdapter
      autoload :CleverLoad
      autoload :ConnectionHandlerExtension
      autoload :FixtureSet
      autoload :LogSubscriber
      autoload :Persistence
      autoload :SchemaDumper
      autoload :Sequencer
      autoload :Relation
      autoload :Transactions
      autoload :TestFixtures
      autoload :AssociationPreloader
      autoload :Association
      autoload :LockingOptimistic
    end

    included do
      include Transactions
      ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(Sequencer)
      ActiveRecord::ConnectionAdapters::AbstractAdapter.prepend(AbstractAdapter)
      ActiveRecord::LogSubscriber.prepend(LogSubscriber)
      ActiveRecord::Persistence.include(Persistence)
      ActiveRecord::Locking::Optimistic.include(LockingOptimistic)
      ActiveRecord::Relation.include(CleverLoad)
      ActiveRecord::Relation.prepend(Relation)
      ActiveRecord::Migration.include(ActiveRecord::Turntable::Migration)
      ActiveRecord::ConnectionAdapters::ConnectionHandler.prepend(ConnectionHandlerExtension)
      ActiveRecord::Associations::Preloader::Association.prepend(AssociationPreloader)
      ActiveRecord::Associations::Association.prepend(Association)
      ActiveRecord::FixtureSet.prepend(FixtureSet)
      ActiveRecord::TestFixtures.prepend(TestFixtures)
      require "active_record/turntable/active_record_ext/migration_proxy"
      require "active_record/turntable/active_record_ext/activerecord_import_ext"
      require "active_record/turntable/active_record_ext/acts_as_archive_extension"
    end
  end
end
