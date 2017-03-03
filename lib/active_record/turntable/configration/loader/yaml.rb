module ActiveRecord::Turntable::Configuration::Loader
  class YAML
    attr_reader :path, :configuration, :dsl

    def initialize(path)
      @path = path
      @configuration = Configuration.new
      @dsl = DSL.new(@configuration)
    end

    def self.load(path, env)
      new(path).load(env)
    end

    def load(env)
      yaml = YAML.load(ERB.new(IO.read(path)).result).with_indifferent_access
      load_clusters(yaml[:clusters])

      configuration
    end

    private

      def load_clusters(clusters_config)
        clusters_config.each do |cluster_name, conf|
          @dsl.cluster cluster_name do
            algorithm conf[:algorithm] if conf[:algorithm]

            if conf[:seq]
              conf[:seq].each do |sequence_name, sequence_conf|
                sequence sequence_name, to: sequence_conf[:connection]
              end
            end

            if conf[:shards]
              current_lower_limit = 0
              conf[:shards].each do |shard_conf|
                upper_limit = shard_conf[:less_than]
                shard current_lower_limit...upper_limit
                current_lower_limit = upper_limit
              end
            end
          end
        end
      end
  end
end
