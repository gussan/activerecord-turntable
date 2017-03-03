module ActiveRecord::Turntable
  class Configuration
    attr_reader :clusters

    def self.configure(&block)
      new.tap { |c| c.configure(&block) }
    end

    def configure(&block)
      DSL.new(self).instance_exec(&block)
    end

    def load_from_yaml(path)
      Loader::YAML.load(path)
    end
  end

  require "active_record/turntable/configuration/dsl"
  require "active_record/turntable/configuration/loader/yaml"
end
