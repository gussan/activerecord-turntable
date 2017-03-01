module ActiveRecord::Turntable
  class Deprecation < ActiveSupport::Deprecation
    def initialize(deprecation_horizon = "3.1",
                   gem_name = "activerecord-turntable")
      super
    end
  end
end
