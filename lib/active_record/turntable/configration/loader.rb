module ActiveRecord::Turntable
  class Configuration
    module Loader
      extend ActiveSupport::Autoload

      autoload :YAML
    end
  end
end
