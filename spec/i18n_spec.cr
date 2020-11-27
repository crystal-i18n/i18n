require "./spec_helper"

describe I18n do
  before_each do
    I18n.config = I18n::Config.new

    I18n.config.loaders << I18n::Loader::YAML.new("spec/locales/yaml")
    I18n.init
  end

  after_each do
    I18n.config = I18n::Config.new
  end

  describe "#activate" do
    it "activates a specific locale for the main catalog" do
      I18n.activate("fr")
      I18n.locale.should eq "fr"
      I18n.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "can process a locale expressed as a symbol" do
      I18n.activate(:fr)
      I18n.locale.should eq "fr"
      I18n.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "raises if the locale is not part of the available locales" do
      expect_raises(I18n::Errors::InvalidLocale, "xy is not a valid locale") do
        I18n.activate("xy")
      end
    end
  end

  describe "#config" do
    it "#returns the main Config object" do
      I18n.config.should be_a I18n::Config
    end
  end

  describe "#config=" do
    it "#allows to set a new Config object" do
      new_config = I18n::Config.new
      I18n.config = new_config
      I18n.config.should eq new_config
    end
  end

  describe "#init" do
    it "#allows to initializes the I18n module" do
      new_config = I18n::Config.new
      new_config.loaders << I18n::Loader::YAML.new("spec/locales/yaml")

      I18n.config = new_config
      I18n.init

      I18n.activate(:fr)
      I18n.translate!("simple.translation").should eq "C'est une traduction simple"
    end
  end

  describe "#locale" do
    it "returns the main catalog locale" do
      I18n.locale.should eq I18n.config.default_locale

      I18n.activate(:fr)
      I18n.locale.should eq "fr"
    end
  end

  describe "#locale=" do
    it "activates a specific locale for the main catalog" do
      I18n.locale = "fr"
      I18n.locale.should eq "fr"
      I18n.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "can process a locale expressed as a symbol" do
      I18n.locale = :fr
      I18n.locale.should eq "fr"
      I18n.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "raises if the locale is not part of the available locales" do
      expect_raises(I18n::Errors::InvalidLocale, "xy is not a valid locale") do
        I18n.locale = "xy"
      end
    end
  end

  describe "#translate" do
    it "is an alias for I18n::Catalog#translate" do
      I18n.locale = "fr"

      I18n.translate("simple.translation").should eq "C'est une traduction simple"
      I18n.translate("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.translate("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      I18n.translate("unknown.translation", name: "John").should eq "missing translation: fr.unknown.translation"
    end
  end

  describe "#t" do
    it "is an alias for #translate" do
      I18n.locale = "fr"

      I18n.t("simple.translation").should eq "C'est une traduction simple"
      I18n.t("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.t("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      I18n.t("unknown.translation", name: "John").should eq "missing translation: fr.unknown.translation"
    end
  end

  describe "#translate!" do
    it "is an alias for I18n::Catalog#translate!" do
      I18n.locale = "fr"

      I18n.translate!("simple.translation").should eq "C'est une traduction simple"
      I18n.translate!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.translate!("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      expect_raises(I18n::Errors::MissingTranslation, "missing translation: fr.unknown.translation") do
        I18n.translate!("unknown.translation")
      end
    end
  end

  describe "#t!" do
    it "is an alias for #translate!" do
      I18n.locale = "fr"

      I18n.t!("simple.translation").should eq "C'est une traduction simple"
      I18n.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.t!("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      expect_raises(I18n::Errors::MissingTranslation, "missing translation: fr.unknown.translation") do
        I18n.t!("unknown.translation")
      end
    end
  end

  describe "#with_locale" do
    it "activates a valid locale in the context of a specific block only" do
      I18n.locale.should eq "en"

      I18n.with_locale("fr") do
        I18n.locale.should eq "fr"
        I18n.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      end

      I18n.locale.should eq "en"
    end

    it "can process a locale expressed as a symbol" do
      I18n.locale.should eq "en"

      I18n.with_locale(:fr) do
        I18n.locale.should eq "fr"
        I18n.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      end

      I18n.locale.should eq "en"
    end

    it "raises if the locale is not part of the available locales" do
      expect_raises(I18n::Errors::InvalidLocale, "xy is not a valid locale") do
        I18n.with_locale("xy") do
        end
      end
    end
  end
end
