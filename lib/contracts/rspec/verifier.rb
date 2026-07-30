# frozen_string_literal: true

require "contracts"

module Contracts
  module RSpec
    module_function

    def verify_all!
      failures = Contracts.registry.all.filter_map do |contract|
        next if contract.method_name == :__invariant__

        owner = contract.owner
        next if owner.method_defined?(contract.method_name) ||
                owner.private_method_defined?(contract.method_name) ||
                owner.protected_method_defined?(contract.method_name)

        "#{contract.id} references a missing method"
      end
      raise Contracts::DefinitionError, failures.join("\n") unless failures.empty?

      true
    end
  end
end
