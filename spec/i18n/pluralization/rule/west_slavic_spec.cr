require "./spec_helper"

describe I18n::Pluralization::Rule::WestSlavic do
  describe "#apply" do
    it "returns :one when expected" do
      rule = I18n::Pluralization::Rule::WestSlavic.new
      rule.apply(1).should eq :one
    end

    it "returns :few when expected" do
      rule = I18n::Pluralization::Rule::WestSlavic.new
      [2, 3, 4].each do |n|
        rule.apply(n).should eq :few
      end
    end

    it "returns :other when expected" do
      rule = I18n::Pluralization::Rule::WestSlavic.new
      [0, 0.5, 1.7, 2.1, 5, 7.8, 10, 875].each do |n|
        rule.apply(n).should eq :other
      end
    end
  end
end
