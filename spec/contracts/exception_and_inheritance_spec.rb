# frozen_string_literal: true
require "spec_helper"

RSpec.describe "exception and inherited contracts" do
  it "preserves permitted exceptions and checks their state postcondition" do
    failure = Class.new(StandardError)
    klass = Class.new do
      include Contracts
      attr_reader :balance
      contract(:call) do
        observe :balance
        raises failure
        on_raise(failure) { |error, before:| error.is_a?(failure) && balance == before.balance }
      end
      def initialize = @balance = 1
      define_method(:call) { raise failure, "expected" }
    end
    expect { klass.new.call }.to raise_error(failure, "expected")
  end

  it "merges a parent contract in merge mode" do
    parent = Class.new do
      include Contracts
      contract(:call) { params value: String; returns String }
      def call(value:) = value
    end
    child = Class.new(parent) do
      contract(:call) { requires { |value:| !value.empty? } }
      def call(value:) = value
    end
    expect { child.new.call(value: 1) }.to raise_error(Contracts::ParameterViolation)
    expect { child.new.call(value: "") }.to raise_error(Contracts::PreconditionViolation)
  end
end
