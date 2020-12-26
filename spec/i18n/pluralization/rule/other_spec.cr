require "./spec_helper"

describe I18n::Pluralization::Rule::Other do
  describe "#apply" do
    it "returns :other when expected" do
      rule = I18n::Pluralization::Rule::Other.new
      [0, 1, 1.2, 2, 5, 11, 21, 22, 27, 99, 1000].each do |n|
        rule.apply(n).should eq :other
      end
    end
  end
end
