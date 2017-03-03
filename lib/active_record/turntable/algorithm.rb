module ActiveRecord::Turntable
  module Algorithm
    extend ActiveSupport::Autoload

    eager_autoload do
      autoload :Base
      autoload :RangeAlgorithm
      autoload :RangeBsearchAlgorithm
      autoload :ModuloAlgorithm
    end

    def class_for(name_or_class)
      case name_or_class
      when Algorithm::Base
        name_or_class
      else
        "#{name_or_class.camelize}Algorithm".constantize
      end
    end
    module_function :class_for
  end
end
