# frozen_string_literal: true
require "spec_helper"

RSpec.describe Contracts do
  let(:klass) do
    Class.new do
      include Contracts
      attr_reader :balance
      invariant("non-negative") { balance >= 0 }
      contract :withdraw do
        params amount: Numeric
        requires("positive") { |amount:| amount.positive? }
        returns Numeric
        changes :balance
        ensures("debits balance") { |result, before:| balance == before.balance - result }
      end
      def initialize(balance:) = @balance = balance
      def withdraw(amount:) = (@balance -= amount; amount)
    end
  end

  it "validates parameters, preconditions, results, postconditions, and snapshots" do
    account = klass.new(balance: 20)
    expect(account.withdraw(amount: 5)).to eq(5)
    expect { account.withdraw(amount: -1) }.to raise_error(Contracts::PreconditionViolation)
    expect { account.withdraw(amount: "five") }.to raise_error(Contracts::ParameterViolation)
  end

  it "attaches a contract declared after its method" do
    after = Class.new do
      include Contracts
      def echo(value:) = value
      contract(:echo) { params value: String; returns String }
    end
    expect(after.new.echo(value: "ok")).to eq("ok")
    expect { after.new.echo(value: 1) }.to raise_error(Contracts::ParameterViolation)
  end

  it "reports mutation and return contract failures" do
    pure = Class.new do
      include Contracts
      attr_reader :count
      contract(:call) { pure; returns String }
      def call = (@count = 1; :bad)
    end
    expect { pure.new.call }.to raise_error(Contracts::ReturnViolation)
  end
end
