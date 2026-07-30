# frozen_string_literal: true
require_relative "transfer_service"
source = BankAccount.new(balance: 100)
destination = BankAccount.new(balance: 25)
puts TransferService.new.call(source: source, destination: destination, amount: 10)
puts Contracts.contract_for(BankAccount, :withdraw).to_json
