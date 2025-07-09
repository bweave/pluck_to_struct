# frozen_string_literal: true

require_relative "pluck_to_struct/version"
require "active_record"
require "active_support/concern"

module PluckToStruct
  extend ActiveSupport::Concern

  @struct_cache = {}
  @struct_cache_mutex = Mutex.new

  class << self
    def struct_cache
      @struct_cache
    end

    def struct_cache_mutex
      @struct_cache_mutex
    end

    def get_or_create_struct_class(model_name, attribute_names)
      struct_name = generate_struct_name(model_name, attribute_names)

      if struct_cache[struct_name]
        return struct_cache[struct_name]
      end

      struct_cache_mutex.synchronize do
        struct_class = Struct.new(struct_name, *attribute_names)
        struct_cache[struct_name] = struct_class

        struct_class
      end
    end

    def generate_struct_name(model_name, attribute_names)
      attributes_hash = attribute_names.map(&:to_s).sort.join("_")
      sanitized_hash = attributes_hash.gsub(/[^a-zA-Z0-9_]/, "_")

      "#{model_name}_PluckToStruct_#{sanitized_hash}"
    end

    def clear_struct_cache!
      struct_cache_mutex.synchronize do
        @struct_cache.each do |name, struct|
          if Object.const_defined?(struct.name)
            Struct.send(:remove_const, struct.name.split("::").last)
          end
        end
        @struct_cache.clear
      end
    end
  end

  class_methods do
    def pluck_to_struct(*columns, klass_name: nil, &block)
      selects = (columns.presence || column_names).map(&:to_s)
      safe_selects = selects.map { |col| Arel.sql(col) }
      plucked_data = pluck(*safe_selects)

      return [] if plucked_data.empty?

      attribute_names = build_attribute_names(selects)
      struct_class = if klass_name
        Object.const_get(klass_name)
      else
        PluckToStruct.get_or_create_struct_class(self.name, attribute_names)
      end

      plucked_data.map do |row|
        row_array = columns.length == 1 ? [ row ] : row
        result = struct_class.new(*row_array)
        block ? block.call(result) : result
      end
    end

    private

    def build_attribute_names(selects)
      selects.map do |select|
        table_and_column, alias_name = select.to_s.split(/\sAS\s/i)
        (alias_name.presence || table_and_column)
          .parameterize
          .underscore
          .remove("#{table_name}_")
          .to_sym
      end
    end
  end
end
