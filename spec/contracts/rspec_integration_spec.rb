# frozen_string_literal: true

require "spec_helper"
require "contracts/rspec"

RSpec.describe "Contracts RSpec integration" do
  it "provides stateful matchers and validates definitions" do
    owner = Class.new do
      include Contracts

      attr_reader :value

      invariant("value is non-negative") { value >= 0 }
      contract(:increment) do
        observe :value
        changes :value
        must_change :value
      end
      def initialize = @value = 0
      def increment = (@value += 1)
    end

    expect(owner).to have_contract(:increment)
    expect(owner).to have_invariant("value is non-negative")
    expect(owner).to observe_state(:value, on: :increment)
    expect(owner).to permit_change(:value, on: :increment)
    expect(owner).to require_change(:value, on: :increment)
    expect(Contracts::RSpec.verify_all!).to be(true)
  end
end
