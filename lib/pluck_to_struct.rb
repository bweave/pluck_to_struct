# frozen_string_literal: true

require_relative "pluck_to_struct/version"
require "active_record"
require "active_support/concern"
require "active_support/inflector"

module PluckToStruct # rubocop:disable Style/Documentation
  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength
    def pluck_to_struct(*selects, custom_klass_name: "")
      columns = (selects.presence || column_names)
      method_names = build_method_names(columns)
      klass_name = custom_klass_name.presence || build_klass_name(columns)
      struct = build_struct(klass_name, method_names)

      pluck(*columns).map { |row_values| struct.new(*row_values) }
    end

    def pluck_to_hash(*selects)
      columns = (selects.presence || column_names)
      method_names = build_method_names(columns)

      pluck(*columns).map do |row_values|
        method_names.zip(Array.wrap(row_values)).to_h
      end
    end

    private

    def build_method_names(columns)
      columns.map do |column|
        table_and_column, alias_name = column.to_s.split(/\sAS\s/i)
        (alias_name.presence || table_and_column)
          .parameterize
          .underscore
          .remove("#{table_name}_")
          .to_sym
      end
    end

    def build_klass_name(columns)
      unique_identifiers = [
        "Plucked",
        *columns.map(&:to_s).map(&:parameterize).map(&:underscore)
      ].compact
      unique_identifiers.join("_")
    end

    def build_struct(klass_name, method_names)
      if const_defined?(klass_name)
        const_get(klass_name)
      else
        const_set(klass_name, Struct.new(*method_names))
      end
    end
  end
end
