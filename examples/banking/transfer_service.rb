# frozen_string_literal: true
require_relative "bank_account"
class TransferService
  include Contracts
  contract :call do
    params source: BankAccount, destination: BankAccount, amount: Numeric
    requires { |source:, destination:, amount:| source != destination && amount.positive? }
    returns TrueClass
  end
  def call(source:, destination:, amount:)
    source.withdraw(amount: amount)
    destination.instance_variable_set(:@balance, destination.balance + amount)
    true
  end
end
