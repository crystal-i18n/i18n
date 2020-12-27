require "./spec_helper"

describe I18n::Locale::Fallbacks do
  describe "::new" do
    it "allows to initialize an empty fallbacks configuration" do
      fallbacks = I18n::Locale::Fallbacks.new
      fallbacks.default.should be_empty
      fallbacks.mapping.should be_empty
    end

    it "allows to initialize a fallbacks configuration with a specific mapping only" do
      fallbacks = I18n::Locale::Fallbacks.new({"fr-CA-special" => ["fr-CA", "fr", "en"]})
      fallbacks.default.should be_empty
      fallbacks.mapping.should eq({"fr-CA-special" => ["fr-CA", "fr", "en"]})
    end

    it "allows to initialize a fallbacks configuration with a default fallback chain only" do
      fallbacks = I18n::Locale::Fallbacks.new(default: ["en-US", "en"])
      fallbacks.default.should eq ["en-US", "en"]
      fallbacks.mapping.should be_empty
    end

    it "allows to initialize a fallbacks configuration with a specific mapping and default fallback chain" do
      fallbacks = I18n::Locale::Fallbacks.new({"fr-CA-special" => ["fr-CA", "fr", "en"]}, default: ["en-US", "en"])
      fallbacks.default.should eq ["en-US", "en"]
      fallbacks.mapping.should eq({"fr-CA-special" => ["fr-CA", "fr", "en"]})
    end
  end

  describe "#for" do
    it "returns the expected fallbacks when the locale is configured in the fallbacks mapping" do
      fallbacks = I18n::Locale::Fallbacks.new({"fr-CA-special" => ["fr-CA", "fr"]}, default: ["en-US", "en"])
      fallbacks.for("fr-CA-special").should eq ["fr-CA-special", "fr-CA", "fr", "en-US", "en"]
    end

    it "returns the expected fallbacks when the locale is not configured in the fallbacks mapping" do
      fallbacks = I18n::Locale::Fallbacks.new({"fr-CA-special" => ["fr-CA", "fr"]}, default: ["en-US", "en"])
      fallbacks.for("fr-CA").should eq ["fr-CA", "fr", "en-US", "en"]
    end
  end
end
