# frozen_string_literal: true

require "contracts"
require_relative "rspec/verifier"
begin
  require "rspec/expectations"
  RSpec::Matchers.define :have_contract do |method_name|
    match { |owner| !Contracts.contract_for(owner, method_name).nil? }
  end
  RSpec::Matchers.define :have_precondition do |method_name|
    match { |owner| (contract = Contracts.contract_for(owner, method_name)) && !contract.preconditions.empty? }
  end
  RSpec::Matchers.define :return_contract do |method_name, constraint|
    match do |owner|
      (contract = Contracts.contract_for(owner,
                                         method_name)) && contract.return_constraint.description == Contracts::Constraints.coerce(constraint).description
    end
  end
  RSpec::Matchers.define :have_invariant do |description|
    match { |owner| Contracts.invariants_for(owner).any? { |invariant| invariant.description == description } }
  end
  RSpec::Matchers.define :observe_state do |field, on:|
    match { |owner| (contract = Contracts.contract_for(owner, on)) && contract.observed_fields.include?(field.to_sym) }
  end
  RSpec::Matchers.define :permit_change do |field, on:|
    match do |owner|
      (contract = Contracts.contract_for(owner, on)) && contract.permitted_changes.include?(field.to_sym)
    end
  end
  RSpec::Matchers.define :require_change do |field, on:|
    match { |owner| (contract = Contracts.contract_for(owner, on)) && contract.required_changes.include?(field.to_sym) }
  end
  RSpec::Matchers.define :have_pure_contract do |method_name|
    match { |owner| (contract = Contracts.contract_for(owner, method_name)) && contract.pure? }
  end

  RSpec::Core::ExampleGroup.define_singleton_method(:describe_contract) do |owner, method_name, &block|
    describe("#{owner}##{method_name}", &block)
  end
rescue LoadError
  # RSpec is optional at runtime.
end
