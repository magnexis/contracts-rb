# frozen_string_literal: true
require "spec_helper"

RSpec.describe "stateful contracts" do
  it "checks initialization invariants and produces immutable deep snapshots" do
    klass = Class.new do
      include Contracts
      attr_reader :balance, :events
      invariant("non-negative") { balance >= 0 }
      contract(:deposit) do
        observe :balance
        observe :events, deep: true
        changes :balance, :events
        must_change :balance
        ensures { |amount, before:| before.events.empty? && balance == before.balance + amount }
      end
      def initialize(balance:) = (@balance = balance; @events = [])
      def deposit(amount:) = (@balance += amount; @events << amount; amount)
    end
    expect { klass.new(balance: -1) }.to raise_error(Contracts::InvariantViolation)
    account = klass.new(balance: 1)
    expect(account.deposit(amount: 2)).to eq(2)
  end

  it "rejects unpermitted observed mutations" do
    klass = Class.new do
      include Contracts
      attr_reader :balance, :status
      contract(:call) { observe :balance, :status; changes :balance }
      def initialize = (@balance = 0; @status = :active)
      def call = (@balance += 1; @status = :closed)
    end
    expect { klass.new.call }.to raise_error(Contracts::MutationViolation)
  end
end
