# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pluck_to_struct"

require "pry"
require "minitest/autorun"
require "minitest/focus"
require "minitest/pride"
require "active_record"

Dir["#{File.dirname(__FILE__)}/support/models/*.rb"].each { |f| require f }
require "support/database"

setup_database

module Minitest
  class Test
    # Helper to define a test method using a String. Under the hood, it replaces
    # spaces with underscores and defines the test method.
    #
    #   test "verify something" do
    #     ...
    #   end
    def self.test(name, &block)
      test_name = "test_#{name.gsub(/\s+/, "_")}".to_sym
      defined = method_defined? test_name
      raise "#{test_name} is already defined in #{self}" if defined

      if block_given?
        define_method(test_name, &block)
      else
        define_method(
          test_name
        ) { flunk "No implementation provided for #{name}" }
      end
    end
  end
end