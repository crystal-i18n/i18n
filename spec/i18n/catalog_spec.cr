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

    it "is able to initialize a catalog of translations with a specific set of available locales" do
      catalog = I18n::Catalog.new(available_locales: ["fr", "en"])
      catalog.available_locales.should eq ["fr", "en"]
    end
  end

  describe "::from_config" do
    it "is able to initialize a catalog of translations from a configuration object" do
      config = I18n::Config.new
      config.available_locales = ["en", "fr"]
      config.default_locale = "fr"
      config.loaders << I18n::Loader::YAML.new("spec/locales/yaml")

      catalog = I18n::Catalog.from_config(config)

      catalog.available_locales.should eq ["en", "fr"]
      catalog.default_locale.should eq "fr"
      catalog.locale.should eq "fr"

      catalog.translate!("simple.translation").should eq "C'est une traduction simple"

      catalog.with_locale("en") do
        catalog.translate!("simple.translation").should eq "This is a simple translation"
      end
    end

    it "is able to initialize a catalog from a config object containing loaders making use of the same namespaces" do
      config = I18n::Config.new
      config.loaders << I18n::Loader::YAML.new("#{__DIR__}/catalog_spec/dir01")
      config.loaders << I18n::Loader::YAML.new("#{__DIR__}/catalog_spec/dir02")

      catalog = I18n::Catalog.from_config(config)

      catalog.translate!("message1").should eq "Message 1"
      catalog.translate!("message2").should eq "Message 2"

      catalog.translate!("simple.translation1").should eq "Simple translation 1"
      catalog.translate!("simple.translation2").should eq "Simple translation 2"

      catalog.translate!("custom1.message").should eq "Custom message 1"
      catalog.translate!("custom2.message").should eq "Custom message 2"

      catalog.translate!("overriden.message").should eq "I am overriden"
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

      catalog.available_locales.to_set.should eq ["en", "fr"].to_set
    end

    it "returns an array with the default locale in it if no translations are available yet" do
      catalog = I18n::Catalog.new

      catalog.available_locales.should eq [catalog.default_locale]
    end
  end

  describe "#inject" do
    it "injects a specific loader into the catalog" do
      catalog = I18n::Catalog.new

      expect_raises(I18n::Errors::MissingTranslation, "missing translation: en.simple.translation") do
        catalog.translate!("simple.translation")
      end

      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml"))

      catalog.translate!("simple.translation").should eq "This is a simple translation"
    end

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

    it "can return a translated and pluralized string with a float count" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate("simple.pluralization", count: 1.5).should eq "1.5 items"
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

    it "can return a translations resolved using a scope expressed as a symbol" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate(:translation, scope: :simple).should eq "This is a simple translation"
    end

    it "can return a translations resolved using a scope expressed as a string" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate(:translation, scope: "simple.nested").should eq "This is a nested translation"
    end

    it "can return a translations resolved using a scope expressed as an array of symbols" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate(:translation, scope: [:simple, :nested]).should eq "This is a nested translation"
    end

    it "can return a translations resolved using a scope expressed as an array of strings" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate(:translation, scope: ["simple", "nested"]).should eq "This is a nested translation"
    end

    it "can fallback to a default value if the translation is missing" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.translate("unknown.translation", default: "Hello").should eq "Hello"
    end

    it "can return a translated string involving interpolated values with params specified as a hash" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      params = Hash(String, String).new
      params["name"] = "John"

      catalog.locale = "fr"
      catalog.translate("simple.interpolation", params).should eq "Bonjour, John!"
    end

    it "can return a translated string involving interpolated values with params specified as a named tuple" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      params = {name: "John"}

      catalog.locale = "fr"
      catalog.translate("simple.interpolation", params).should eq "Bonjour, John!"
    end

    it "makes use of fallbacks when fallbacks are configured" do
      catalog = I18n::Catalog.new(
        default_locale: "en",
        available_locales: ["fr-CA-special", "fr-CA", "fr", "en"],
        fallbacks: I18n::Locale::Fallbacks.new({"fr-CA-special": ["fr-CA", "fr", "en"]})
      )
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.activate("fr-CA-special")
      catalog.translate("simple.translation").should eq "C'est une traduction simple"

      catalog.activate("en")
      catalog.translate("simple.translation").should eq "This is a simple translation"
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

    it "can return a translated and pluralized string with a float count" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!("simple.pluralization", count: 1.5).should eq "1.5 items"
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

    it "can return a translations resolved using a scope expressed as a symbol" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!(:translation, scope: :simple).should eq "This is a simple translation"
    end

    it "can return a translations resolved using a scope expressed as a string" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!(:translation, scope: "simple.nested").should eq "This is a nested translation"
    end

    it "can return a translations resolved using a scope expressed as an array of symbols" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!(:translation, scope: [:simple, :nested]).should eq "This is a nested translation"
    end

    it "can return a translations resolved using a scope expressed as an array of strings" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)
      catalog.translate!(:translation, scope: ["simple", "nested"]).should eq "This is a nested translation"
    end

    it "can fallback to a default value if the translation is missing" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.translate!("unknown.translation", default: "Hello").should eq "Hello"
    end

    it "can return a translated string involving interpolated values with params specified as a hash" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      params = Hash(String, String).new
      params["name"] = "John"

      catalog.locale = "fr"
      catalog.translate!("simple.interpolation", params).should eq "Bonjour, John!"
    end

    it "can return a translated string involving interpolated values with params specified as a named tuple" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      params = {name: "John"}

      catalog.locale = "fr"
      catalog.translate!("simple.interpolation", params).should eq "Bonjour, John!"
    end

    it "makes use of fallbacks when fallbacks are configured" do
      catalog = I18n::Catalog.new(
        default_locale: "en",
        available_locales: ["fr-CA-special", "fr-CA", "fr", "en"],
        fallbacks: I18n::Locale::Fallbacks.new({"fr-CA-special": ["fr-CA", "fr", "en"]})
      )
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.activate("fr-CA-special")
      catalog.translate!("simple.translation").should eq "C'est une traduction simple"

      catalog.activate("en")
      catalog.translate!("simple.translation").should eq "This is a simple translation"
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
      catalog.t("simple.interpolation", {name: "John"}).should eq "Bonjour, John!"
      catalog.t("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      catalog.t("simple.pluralization", count: 5.5).should eq "5.5 objets"
      catalog.t(:translation, scope: "simple.nested").should eq "C'est une traduction imbriquée"
      catalog.t("unknown.translation", name: "John").should eq "missing translation: fr.unknown.translation"
      catalog.t("unknown.translation", default: "Hello").should eq "Hello"
    end
  end

  describe "#t!" do
    it "is an alias for #translate!" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.locale = "fr"

      catalog.t!("simple.translation").should eq "C'est une traduction simple"
      catalog.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      catalog.t!("simple.interpolation", {name: "John"}).should eq "Bonjour, John!"
      catalog.t!("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      catalog.t!("simple.pluralization", count: 5.5).should eq "5.5 objets"
      catalog.t!(:translation, scope: "simple.nested").should eq "C'est une traduction imbriquée"
      catalog.t!("unknown.translation", default: "Hello").should eq "Hello"
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

  describe "#localize" do
    it "allows to localize a datetime using the default format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time).should eq "Mon, 15 Feb 2016 10:20:30 +0000"
      catalog.activate("fr")
      catalog.localize(time).should eq "15 février 2016 10h 20min 30s"
    end

    it "allows to localize a datetime using the short format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time, :short).should eq "15 Feb 10:20"
      catalog.activate("fr")
      catalog.localize(time, :short).should eq "15 fév. 10h20"
    end

    it "allows to localize a datetime using the long format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time, :long).should eq "February 15, 2016 10:20"
      catalog.activate("fr")
      catalog.localize(time, :long).should eq "lundi 15 février 2016 10h20"
    end

    it "allows to localize a datetime using a custom format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"
      catalog.activate("fr")
      catalog.localize(time, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
    end

    it "allows to localize a date using the default format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time.date).should eq "2016-02-15"
      catalog.activate("fr")
      catalog.localize(time.date).should eq "15/02/2016"
    end

    it "allows to localize a date using the short format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time.date, :short).should eq "Feb 15"
      catalog.activate("fr")
      catalog.localize(time.date, :short).should eq "15 fév."
    end

    it "allows to localize a date using the long format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time.date, :long).should eq "February 15, 2016"
      catalog.activate("fr")
      catalog.localize(time.date, :long).should eq "15 février 2016"
    end

    it "allows to localize a date using a custom format" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.localize(time.date, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"
      catalog.activate("fr")
      catalog.localize(time.date, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
    end

    it "allows to localize numbers" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.localize(123_456).should eq "123,456"
      catalog.localize(123_456.789).should eq "123,456.789"
      catalog.activate("fr")
      catalog.localize(123_456).should eq "123 456"
      catalog.localize(123_456.789).should eq "123 456,789"
    end

    it "allows to localize numbers using custom formats" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      catalog.localize(123_456.789, :custom).should eq "123,456.79"
      catalog.activate("fr")
      catalog.localize(123_456.789, :custom).should eq "123 456,79"
    end
  end

  describe "#l" do
    it "is an alias for #localize" do
      catalog = I18n::Catalog.new
      catalog.inject(I18n::Loader::YAML.new("spec/locales/yaml").load)

      time = Time.utc(2016, 2, 15, 10, 20, 30)

      catalog.l(time).should eq "Mon, 15 Feb 2016 10:20:30 +0000"
      catalog.l(time, :short).should eq "15 Feb 10:20"
      catalog.l(time, :long).should eq "February 15, 2016 10:20"
      catalog.l(time, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"
      catalog.l(time.date).should eq "2016-02-15"
      catalog.l(time.date, :short).should eq "Feb 15"
      catalog.l(time.date, :long).should eq "February 15, 2016"
      catalog.l(time.date, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"
      catalog.l(123_456).should eq "123,456"
      catalog.l(123_456.789).should eq "123,456.789"
      catalog.l(123_456.789, :custom).should eq "123,456.79"

      catalog.activate("fr")

      catalog.l(time).should eq "15 février 2016 10h 20min 30s"
      catalog.l(time, :short).should eq "15 fév. 10h20"
      catalog.l(time, :long).should eq "lundi 15 février 2016 10h20"
      catalog.l(time, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
      catalog.l(time.date).should eq "15/02/2016"
      catalog.l(time.date, :short).should eq "15 fév."
      catalog.l(time.date, :long).should eq "15 février 2016"
      catalog.l(time.date, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
      catalog.l(123_456).should eq "123 456"
      catalog.l(123_456.789).should eq "123 456,789"
      catalog.l(123_456.789, :custom).should eq "123 456,79"
    end
  end
end
