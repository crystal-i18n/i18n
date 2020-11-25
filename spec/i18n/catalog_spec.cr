require "./spec_helper"

describe I18n::Catalog do
  describe "::new" do
    it "initializes a catalog of translations with the expected default values" do
      catalog = I18n::Catalog.new
      catalog.default_locale.should eq I18n::Catalog::DEFAULT_LOCALE
      catalog.locale.should eq I18n::Catalog::DEFAULT_LOCALE
    end

    it "is able to initialize a catalog of translations with a specific default locale" do
      catalog = I18n::Catalog.new(default_locale: "fr")
      catalog.default_locale.should eq "fr"
      catalog.locale.should eq "fr"
    end
  end

  describe "::from_config" do
    it "is able to initialize a catalog of translations from a configuration object" do
      config = I18n::Config.new
      config.default_locale = "fr"
      config.loaders << I18n::Loader::YAML.new("spec/locales/yaml")

      catalog = I18n::Catalog.from_config(config)

      catalog.default_locale.should eq "fr"
      catalog.locale.should eq "fr"

      catalog.translate!("simple.translation").should eq "C'est une traduction simple"

      catalog.with_locale("en") do
        catalog.translate!("simple.translation").should eq "This is a simple translation"
      end
    end
  end

  describe "#activate" do
    it "activates a specific locale for a catalog" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.activate("fr")
      catalog.locale.should eq "fr"
      catalog.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "can process a locale expressed as a symbol" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.activate(:fr)
      catalog.locale.should eq "fr"
      catalog.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "raises if the locale is not part of the available locales" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      expect_raises(I18n::Errors::InvalidLocale, "xy is not a valid locale") do
        catalog.activate("xy")
      end
    end
  end

  describe "#available_locales" do
    it "returns the available locales" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.available_locales.should eq ["en", "fr"]
    end

    it "returns an array with the default locale in it if no translations are available yet" do
      catalog = I18n::Catalog.new

      catalog.available_locales.should eq [catalog.default_locale]
    end
  end

  describe "#inject" do
    it "injects a hash of translations into the catalog" do
      catalog = I18n::Catalog.new

      expect_raises(I18n::Errors::MissingTranslation, "missing translation: en.simple.translation") do
        catalog.translate!("simple.translation")
      end

      catalog.inject({"en" => {"simple" => {"translation" => "This is a test"}}})

      catalog.translate!("simple.translation").should eq "This is a test"
    end
  end

  describe "#locale" do
    it "returns the default locale by default" do
      catalog = I18n::Catalog.new
      catalog.locale.should eq catalog.default_locale
    end

    it "returns the currently activated locale if applicable" do
      catalog = I18n::Catalog.new
      catalog.inject({"fr" => {"simple" => {"translation" => "Ceci est un test"}}})
      catalog.activate("fr")
      catalog.locale.should eq "fr"
    end
  end

  describe "#locale=" do
    it "activates a specific locale for a catalog" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"
      catalog.locale.should eq "fr"
      catalog.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "can process a locale expressed as a symbol" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = :fr
      catalog.locale.should eq "fr"
      catalog.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "raises if the locale is not part of the available locales" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      expect_raises(I18n::Errors::InvalidLocale, "xy is not a valid locale") do
        catalog.locale = "xy"
      end
    end
  end

  describe "#translate" do
    it "can return a simple translated string" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"
      catalog.translate("simple.translation").should eq "C'est une traduction simple"
    end

    it "can return a translated string involving interpolated values" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"
      catalog.translate("simple.interpolation", name: "John").should eq "Bonjour, John!"
    end

    it "can process a translation key expressed as a symbol" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate(:top_level).should eq "This is a top-level translation"
    end

    it "can return a translated and pluralized string" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate("simple.pluralization", count: 0).should eq "0 items"
      catalog.translate("simple.pluralization", count: 1).should eq "One item"
      catalog.translate("simple.pluralization", count: 42).should eq "42 items"
    end

    it "always ensure that zero pluralization rules have precedence if applicable" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate("simple.pluralization_with_zero", count: 0).should eq "No items"
      catalog.translate("simple.pluralization_with_zero", count: 1).should eq "One item"
      catalog.translate("simple.pluralization_with_zero", count: 42).should eq "42 items"
    end

    it "is able to pluralize and interpolate at the same time" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate("simple.pluralization_and_interpolation", count: 0, name: "John").should eq "0 items for John!"
      catalog.translate("simple.pluralization_and_interpolation", count: 1, name: "John").should eq "One item for John!"
      catalog.translate("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 items for John!"
    end

    it "returns a default fallback string if the translation is missing" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.translate("unknown.translation", name: "John").should eq "missing translation: en.unknown.translation"
    end
  end

  describe "#translate!" do
    it "can return a simple translated string" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"
      catalog.translate!("simple.translation").should eq "C'est une traduction simple"
    end

    it "can return a translated string involving interpolated values" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"
      catalog.translate!("simple.interpolation", name: "John").should eq "Bonjour, John!"
    end

    it "can process a translation key expressed as a symbol" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!(:top_level).should eq "This is a top-level translation"
    end

    it "can return a translated and pluralized string" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!("simple.pluralization", count: 0).should eq "0 items"
      catalog.translate!("simple.pluralization", count: 1).should eq "One item"
      catalog.translate!("simple.pluralization", count: 42).should eq "42 items"
    end

    it "always ensure that zero pluralization rules have precedence if applicable" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!("simple.pluralization_with_zero", count: 0).should eq "No items"
      catalog.translate!("simple.pluralization_with_zero", count: 1).should eq "One item"
      catalog.translate!("simple.pluralization_with_zero", count: 42).should eq "42 items"
    end

    it "is able to pluralize and interpolate at the same time" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!("simple.pluralization_and_interpolation", count: 0, name: "John").should eq "0 items for John!"
      catalog.translate!("simple.pluralization_and_interpolation", count: 1, name: "John").should(
        eq "One item for John!"
      )
      catalog.translate!("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 items for John!"
    end

    it "raises an error if the translation is missing" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      expect_raises(I18n::Errors::MissingTranslation, "missing translation: en.unknown.translation") do
        catalog.translate!("unknown.translation")
      end
    end
  end

  describe "#t" do
    it "is an alias for #translate" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"

      catalog.t("simple.translation").should eq "C'est une traduction simple"
      catalog.t("simple.interpolation", name: "John").should eq "Bonjour, John!"
      catalog.t("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      catalog.t("unknown.translation", name: "John").should eq "missing translation: fr.unknown.translation"
    end
  end

  describe "#t!" do
    it "is an alias for #translate!" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"

      catalog.t!("simple.translation").should eq "C'est une traduction simple"
      catalog.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      catalog.t!("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      expect_raises(I18n::Errors::MissingTranslation, "missing translation: fr.unknown.translation") do
        catalog.t!("unknown.translation")
      end
    end
  end

  describe "#with_locale" do
    it "activates a valid locale in the context of a specific block only" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale.should eq "en"

      catalog.with_locale("fr") do
        catalog.locale.should eq "fr"
        catalog.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      end

      catalog.locale.should eq "en"
    end

    it "can process a locale expressed as a symbol" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale.should eq "en"

      catalog.with_locale(:fr) do
        catalog.locale.should eq "fr"
        catalog.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      end

      catalog.locale.should eq "en"
    end

    it "raises if the locale is not part of the available locales" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      expect_raises(I18n::Errors::InvalidLocale, "xy is not a valid locale") do
        catalog.with_locale("xy") do
        end
      end
    end
  end
end
