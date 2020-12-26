require "./spec_helper"

describe I18n::Pluralization::Rule::OneWithZeroOther do
  describe "#apply" do
    it "returns :one when expected" do
      rule = I18n::Pluralization::Rule::OneWithZeroOther.new
      rule.apply(0).should eq :one
      rule.apply(1).should eq :one
    end

    it "returns :other when expected" do
      rule = I18n::Pluralization::Rule::OneWithZeroOther.new
      [0.4, 1.2, 2, 5, 11, 21, 22, 27, 99, 1000].each do |n|
        rule.apply(n).should eq :other
      end
    end
  end
end
