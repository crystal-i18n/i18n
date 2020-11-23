require "./spec_helper"

describe I18n::Config do
  describe "::new" do
    it "initializes a configuration object with the expected default configuration" do
      config = I18n::Config.new
      config.default_locale.should eq I18n::Catalog::DEFAULT_LOCALE
      config.loaders.should eq Array(I18n::Loader::Base).new
    end
  end

  describe "#default_locale" do
    it "returns the expected default locale if not explicitlt configured" do
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
end
