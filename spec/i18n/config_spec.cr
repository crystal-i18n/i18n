require "./spec_helper"

describe I18n::Config do
  describe "::new" do
    it "initializes a configuration object with the expected default configuration" do
      config = I18n::Config.new
      config.default_locale.should eq I18n::Catalog::DEFAULT_LOCALE
      config.loaders.should eq Array(I18n::Loader::Base).new
    end
  end

  describe "#available_locales" do
    it "returns nil if not explicitly configured" do
      config = I18n::Config.new
      config.available_locales.should be_nil
    end

    it "returns the configured available locales if applicable" do
      config = I18n::Config.new
      config.available_locales = [:en, "fr-CA"]
      config.available_locales.should eq ["en", "fr-CA"]
      config.available_locales = nil
      config.available_locales.should be_nil
    end
  end

  describe "#available_locales=" do
    it "allows to configure the available available locales" do
      config = I18n::Config.new
      config.available_locales = [:en, "fr-CA"]
      config.available_locales.should eq ["en", "fr-CA"]
      config.available_locales = nil
      config.available_locales.should be_nil
    end
  end

  describe "#default_locale" do
    it "returns the expected default locale if not explicitly configured" do
      config = I18n::Config.new
      config.default_locale.should eq I18n::Catalog::DEFAULT_LOCALE
    end

    it "returns the configured default locale if applicable" do
      config = I18n::Config.new
      config.default_locale = "fr"
      config.default_locale.should eq "fr"
    end
  end

  describe "#default_locale=" do
    it "allows to configure the default locale from a string" do
      config = I18n::Config.new
      config.default_locale = "es"
      config.default_locale.should eq "es"
    end

    it "allows to configure the default locale from a symbol" do
      config = I18n::Config.new
      config.default_locale = :es
      config.default_locale.should eq "es"
    end
  end

  describe "#loaders" do
    it "returns an empty array of loader instances by default" do
      config = I18n::Config.new
      config.loaders.should eq Array(I18n::Loader::Base).new
    end

    it "can be used to append loader instances" do
      config = I18n::Config.new
      config.loaders << I18n::Loader::YAML.new("config/locales")
      config.loaders.size.should eq 1
    end
  end

  describe "#loaders=" do
    it "allows to set the array of loader instances" do
      config = I18n::Config.new
      config.loaders = [I18n::Loader::YAML.new("config/locales")] of I18n::Loader::Base
      config.loaders.size.should eq 1
    end
  end

  describe "#fallbacks" do
    it "returns nil by default" do
      config = I18n::Config.new
      config.fallbacks.should be_nil
    end

    it "returns the configured fallbacks if applicable" do
      config = I18n::Config.new
      config.fallbacks = I18n::Locale::Fallbacks.new({"fr-CA-special": ["fr-CA", "fr", "en"]})
      config.fallbacks.should be_a I18n::Locale::Fallbacks
    end
  end

  describe "#fallbacks=" do
    it "allows to reset the configured fallbacks when nil is used" do
      config = I18n::Config.new
      config.fallbacks = I18n::Locale::Fallbacks.new({"fr-CA-special" => ["fr-CA", "fr", "en"]})
      config.fallbacks = nil
      config.fallbacks.should be_nil
    end

    it "allows to specify a fallback mapping directly from a hash" do
      config = I18n::Config.new
      config.fallbacks = {"fr-CA-special" => ["fr-CA", "fr", "en"], "en-US" => "en"}
      config.fallbacks.should be_a I18n::Locale::Fallbacks
      config.fallbacks.not_nil!.mapping.should eq({"fr-CA-special" => ["fr-CA", "fr", "en"], "en-US" => ["en"]})
      config.fallbacks.not_nil!.default.should be_empty
    end

    it "allows to specify a fallback mapping directly from a named tuple" do
      config = I18n::Config.new
      config.fallbacks = {en: "fr"}
      config.fallbacks.should be_a I18n::Locale::Fallbacks
      config.fallbacks.not_nil!.mapping.should eq({"en" => ["fr"]})
      config.fallbacks.not_nil!.default.should be_empty
    end

    it "allows to specify a default fallback chain from an array" do
      config = I18n::Config.new
      config.fallbacks = ["en-US", "en"]
      config.fallbacks.should be_a I18n::Locale::Fallbacks
      config.fallbacks.not_nil!.mapping.should be_empty
      config.fallbacks.not_nil!.default.should eq ["en-US", "en"]
    end

    it "allows to specify a fallback object" do
      config = I18n::Config.new
      config.fallbacks = I18n::Locale::Fallbacks.new({"fr-CA-special": ["fr-CA", "fr", "en"]}, default: ["en-US", "en"])
      config.fallbacks.should be_a I18n::Locale::Fallbacks
      config.fallbacks.not_nil!.mapping.should eq({"fr-CA-special" => ["fr-CA", "fr", "en"]})
      config.fallbacks.not_nil!.default.should eq ["en-US", "en"]
    end
  end
end
