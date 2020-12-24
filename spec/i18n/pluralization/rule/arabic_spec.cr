require "./spec_helper"

describe I18n::Pluralization::Rule::Arabic do
  describe "#apply" do
    it "returns :zero if count is 0" do
      rule = I18n::Pluralization::Rule::Arabic.new
      rule.apply(0).should eq :zero
    end

    it "returns :one if count is 1" do
      rule = I18n::Pluralization::Rule::Arabic.new
      rule.apply(1).should eq :one
    end

    it "returns :two if count is 2" do
      rule = I18n::Pluralization::Rule::Arabic.new
      rule.apply(2).should eq :two
    end

    it "returns :few when expected" do
      rule = I18n::Pluralization::Rule::Arabic.new
      [3, 4, 9].each do |count|
        rule.apply(count).should eq :few
      end
    end

    it "returns :many when applicable" do
      rule = I18n::Pluralization::Rule::Arabic.new
      [11, 50, 73].each do |count|
        rule.apply(count).should eq :many
      end
    end

    it "returns :other for all other cases" do
      rule = I18n::Pluralization::Rule::Arabic.new
      rule.apply(2.4).should eq :other
      rule.apply(101).should eq :other
    end
  end
end
