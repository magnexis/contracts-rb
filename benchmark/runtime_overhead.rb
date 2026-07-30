# frozen_string_literal: true

require "benchmark/ips"
require_relative "../lib/contracts"
class Plain
  def call(value:)
    value + 1
  end
end

class Checked
  include Contracts

  contract(:call) do
    params value: Integer
    returns Integer
  end
  def call(value:) = value + 1
end
plain = Plain.new
checked = Checked.new
Benchmark.ips do |x|
  x.report("plain") { plain.call(value: 1) }
  x.report("contract") do
    checked.call(value: 1)
  end
  x.compare!
end
