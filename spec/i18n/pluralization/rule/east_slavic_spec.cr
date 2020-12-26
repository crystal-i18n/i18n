require "./spec_helper"

describe I18n::Pluralization::Rule::EastSlavic do
  describe "#apply" do
    it "returns :one when expected" do
      rule = I18n::Pluralization::Rule::EastSlavic.new
      [1, 21, 51, 71, 101, 1031].each do |n|
        rule.apply(n).should eq :one
      end
    end

    it "returns :few when expected" do
      rule = I18n::Pluralization::Rule::EastSlavic.new
      [2, 3, 4, 22, 23, 24, 92, 93, 94].each do |n|
        rule.apply(n).should eq :few
      end
    end

    it "returns :many when expected" do
      rule = I18n::Pluralization::Rule::EastSlavic.new
      [0, 5, 8, 10, 11, 18, 20, 25, 27, 30, 35, 38, 40].each do |n|
        rule.apply(n).should eq :many
      end
    end

    it "returns :other when expected" do
      rule = I18n::Pluralization::Rule::EastSlavic.new
      [1.2, 3.7, 11.5, 20.8, 1004.3].each do |n|
        rule.apply(n).should eq :other
      end
    end
  end
end
