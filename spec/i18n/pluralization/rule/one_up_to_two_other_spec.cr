require "./spec_helper"

describe I18n::Pluralization::Rule::OneUpToTwoOther do
  describe "#apply" do
    it "returns :one when expected" do
      rule = I18n::Pluralization::Rule::OneUpToTwoOther.new
      [0, 0.5, 1, 1.2, 1.8].each do |n|
        rule.apply(n).should eq :one
      end
    end

    it "returns :other when expected" do
      rule = I18n::Pluralization::Rule::OneUpToTwoOther.new
      [2, 2.1, 5, 11, 21, 22, 37, 40, 900.5].each do |n|
        rule.apply(n).should eq :other
      end
    end
  end
end
