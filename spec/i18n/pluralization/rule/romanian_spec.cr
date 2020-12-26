require "./spec_helper"

describe I18n::Pluralization::Rule::Romanian do
  describe "#apply" do
    it "returns :one when expected" do
      rule = I18n::Pluralization::Rule::Romanian.new
      rule.apply(1).should eq :one
    end

    it "returns :few when expected" do
      rule = I18n::Pluralization::Rule::Romanian.new
      [0, 2, 3, 5, 8, 9, 10, 11, 15, 19, 101, 106, 112, 117, 119, 201].each do |n|
        rule.apply(n).should eq :few
      end
    end

    it "returns :other when expected" do
      rule = I18n::Pluralization::Rule::Romanian.new
      [0.4, 1.7, 20, 21, 23, 34, 45, 66, 89, 100, 120, 138].each do |n|
        rule.apply(n).should eq :other
      end
    end
  end
end
