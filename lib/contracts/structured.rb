# frozen_string_literal: true

require "contracts"

module Contracts
  module Constraints
    # Matches a fixed-length Array whose positions use independent constraints.
    class Tuple < Base
      def initialize(*items)
        @items = items.map { |item| Constraints.coerce(item) }.freeze
      end

      def matches?(value)
        value.is_a?(Array) && value.length == @items.length &&
          @items.each_with_index.all? { |constraint, index| constraint.matches?(value[index]) }
      end

      def description
        "Tuple<#{@items.map(&:description).join(', ')}>"
      end

      def to_h
        super.merge(items: @items.map(&:description))
      end
    end

    # Matches a Hash with required and optional key contracts.
    class Shape < Base
      attr_reader :required, :optional, :allow_extra

      def initialize(required: {}, optional: {}, allow_extra: false)
        @required = coerce_map(required)
        @optional = coerce_map(optional)
        overlap = @required.keys & @optional.keys
        raise DefinitionError, "shape keys cannot be both required and optional: #{overlap.join(', ')}" unless overlap.empty?

        @allow_extra = allow_extra
        freeze
      end

      def matches?(value)
        return false unless value.is_a?(Hash)
        return false unless required.all? { |key, constraint| value.key?(key) && constraint.matches?(value[key]) }
        return false unless optional.all? { |key, constraint| !value.key?(key) || constraint.matches?(value[key]) }
        return true if allow_extra

        (value.keys - required.keys - optional.keys).empty?
      end

      def description
        required_text = required.map { |key, constraint| "#{key}: #{constraint.description}" }
        optional_text = optional.map { |key, constraint| "#{key}?: #{constraint.description}" }
        suffix = allow_extra ? ", ..." : ""
        "Shape<{#{(required_text + optional_text).join(', ')}#{suffix}}>"
      end

      def to_h
        super.merge(
          required: required.transform_values(&:description),
          optional: optional.transform_values(&:description),
          allow_extra: allow_extra
        )
      end

      private

      def coerce_map(values)
        values.to_h.transform_values { |constraint| Constraints.coerce(constraint) }.freeze
      end
    end

    module_function

    # Creates a fixed-length heterogeneous Array constraint.
    def tuple(*items)
      Tuple.new(*items)
    end

    # Creates a required/optional Hash shape constraint.
    def shape(required: {}, optional: {}, allow_extra: false)
      Shape.new(required:, optional:, allow_extra:)
    end
  end
end
