# frozen_string_literal: true

require "spec_helper"
require "contracts/structured"

RSpec.describe "structured constraints" do
  describe Contracts::Constraints::Tuple do
    subject(:constraint) { Contracts::Constraints.tuple(String, Integer) }

    it "matches fixed-length heterogeneous arrays" do
      expect(constraint.matches?(["job", 3])).to be(true)
      expect(constraint.matches?(["job", "3"])).to be(false)
      expect(constraint.matches?(["job", 3, true])).to be(false)
    end

    it "describes each position" do
      expect(constraint.description).to eq("Tuple<String, Integer>")
    end
  end

  describe Contracts::Constraints::Shape do
    subject(:constraint) do
      Contracts::Constraints.shape(
        required: {name: String, count: Integer},
        optional: {tags: Contracts::Constraints::ArrayOf.new(String)}
      )
    end

    it "matches required and optional keys" do
      expect(constraint.matches?({name: "queue", count: 2})).to be(true)
      expect(constraint.matches?({name: "queue", count: 2, tags: ["critical"]})).to be(true)
      expect(constraint.matches?({name: "queue"})).to be(false)
      expect(constraint.matches?({name: "queue", count: 2, extra: true})).to be(false)
    end

    it "can allow additional keys" do
      open_shape = Contracts::Constraints.shape(required: {name: String}, allow_extra: true)
      expect(open_shape.matches?({name: "queue", metadata: {owner: "ops"}})).to be(true)
    end

    it "rejects overlapping required and optional keys" do
      expect do
        Contracts::Constraints.shape(required: {name: String}, optional: {name: String})
      end.to raise_error(Contracts::DefinitionError)
    end
  end
end
