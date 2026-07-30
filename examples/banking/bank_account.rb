# frozen_string_literal: true
require "contracts"

class BankAccount
  include Contracts
  attr_reader :balance, :status, :audit_log
  invariant("balance cannot be negative") { balance >= 0 }
  invariant("status is valid") { %i[active frozen closed].include?(status) }

  contract :withdraw do
    params amount: Numeric
    observe :balance
    observe :audit_log, deep: true
    changes :balance, :audit_log
    requires("positive amount") { |amount:| amount.positive? }
    requires("active account") { status == :active }
    ensures { |result, amount:, before:| result == amount && balance == before.balance - amount }
  end
  def initialize(balance:, status: :active) = (@balance = balance; @status = status; @audit_log = [])
  def withdraw(amount:) = (@balance -= amount; @audit_log << { action: :withdraw, amount: amount }; amount)
end
