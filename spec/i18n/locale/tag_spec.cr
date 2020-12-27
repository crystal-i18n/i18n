require "./spec_helper"

describe I18n::Locale::Tag do
  describe "#==" do
    it "returns true if the two objects are the same" do
      tag = I18n::Locale::Tag.new("fr")
      (tag == tag).should be_true
    end

    it "returns true if the two objects correspond to the same tag" do
      tag_1 = I18n::Locale::Tag.new("fr")
      tag_2 = I18n::Locale::Tag.new("fr")

      (tag_1 == tag_2).should be_true
    end

    it "returns true if the two objects correspond to different tags" do
      tag_1 = I18n::Locale::Tag.new("fr")
      tag_2 = I18n::Locale::Tag.new("en")

      (tag_1 == tag_2).should be_false
    end
  end

  describe "#parent" do
    it "returns nil if the locale tag does not have a parent" do
      I18n::Locale::Tag.new("fr").parent.should be_nil
    end

    it "returns nil if the locale tag does not have a parent" do
      I18n::Locale::Tag.new("fr-CA").parent.should eq I18n::Locale::Tag.new("fr")
    end
  end

  describe "#parents" do
    it "returns an empty array if the locale tag does not have a parent" do
      I18n::Locale::Tag.new("fr").parents.should be_empty
    end

    it "returns the expected array if the locale tag have parents" do
      I18n::Locale::Tag.new("fr-CA-special").parents.should eq(
        [
          I18n::Locale::Tag.new("fr-CA"),
          I18n::Locale::Tag.new("fr"),
        ]
      )
    end
  end

  describe "#to_s" do
    it "returns the locale tag as a string" do
      I18n::Locale::Tag.new("fr").to_s.should eq "fr"
      I18n::Locale::Tag.new("fr-CA").to_s.should eq "fr-CA"
    end
  end
end
