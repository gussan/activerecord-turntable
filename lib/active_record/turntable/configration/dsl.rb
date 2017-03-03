require 'active_record/turntable/configuration'

module ActiveRecord::Turntable
  class Configuration
    class DSL
      attr_reader :configuration

      def initialize(configuration = Configuration.new)
        @configuration = configuration
      end

      def cluster(name, &block)
        configuration.clusters.add ClusterDSL.new(configuration).instance_exec(&block).cluster
      end

      class ClusterDSL < DSL
        attr_reader :cluster

        def initialize
          @cluster = Cluster.new
        end

        def algorithm(name, options = {})
          @cluster.algorithm = Algorithm.class_for(name).new(cluster)
        end

        def sequence(sequence_name, to: connection_name)
          @cluster.sequences.add Shard.new(connection: connection_name)
        end

        def shard(range, to: connection_name)
          @cluster.shards.add Shard.new(connection: connection_name)
        end
      end
    end
  end
end
