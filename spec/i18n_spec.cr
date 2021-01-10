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

    it "is scoped to the current fiber" do
      I18n.locale.should eq "en"

      spawn do
        I18n.config.available_locales = [:en, :fr]
        I18n.activate("fr")
      end

      sleep 1.second

      I18n.locale.should eq "en"
    end
  end

  describe "#available_locales" do
    it "returns the available locales" do
      I18n.available_locales.to_set.should eq ["en", "fr"].to_set
    end

    it "returns an array with the default locale in it if no translations are available yet" do
      I18n.config = I18n::Config.new
      I18n.init

      I18n.available_locales.should eq [I18n.config.default_locale]
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

    it "is scoped to the current fiber" do
      I18n.locale.should eq "en"

      spawn do
        I18n.config.available_locales = [:en, :fr]
        I18n.locale = "fr"
      end

      sleep 1.second

      I18n.locale.should eq "en"
    end
  end

  describe "#translate" do
    it "is an alias for I18n::Catalog#translate" do
      I18n.locale = "fr"

      I18n.translate("simple.translation").should eq "C'est une traduction simple"
      I18n.translate("splitted.translation").should eq "Ceci est une traduction définie séparément"
      I18n.translate("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.translate("simple.interpolation", {name: "John"}).should eq "Bonjour, John!"
      I18n.translate("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      I18n.translate("simple.pluralization", count: 5.5).should eq "5.5 objets"
      I18n.translate(:translation, scope: "simple.nested").should eq "C'est une traduction imbriquée"
      I18n.translate("unknown.translation", default: "Hello").should eq "Hello"
      I18n.translate("unknown.translation", name: "John").should eq "missing translation: fr.unknown.translation"
    end
  end

  describe "#t" do
    it "is an alias for #translate" do
      I18n.locale = "fr"

      I18n.t("simple.translation").should eq "C'est une traduction simple"
      I18n.t("splitted.translation").should eq "Ceci est une traduction définie séparément"
      I18n.t("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.t("simple.interpolation", {name: "John"}).should eq "Bonjour, John!"
      I18n.t("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      I18n.t("simple.pluralization", count: 5.5).should eq "5.5 objets"
      I18n.t(:translation, scope: "simple.nested").should eq "C'est une traduction imbriquée"
      I18n.t("unknown.translation", default: "Hello").should eq "Hello"
      I18n.t("unknown.translation", name: "John").should eq "missing translation: fr.unknown.translation"
    end
  end

  describe "#translate!" do
    it "is an alias for I18n::Catalog#translate!" do
      I18n.locale = "fr"

      I18n.translate!("simple.translation").should eq "C'est une traduction simple"
      I18n.translate!("splitted.translation").should eq "Ceci est une traduction définie séparément"
      I18n.translate!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.translate!("simple.interpolation", {name: "John"}).should eq "Bonjour, John!"
      I18n.translate!("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      I18n.translate!("simple.pluralization", count: 5.5).should eq "5.5 objets"
      I18n.translate!(:translation, scope: "simple.nested").should eq "C'est une traduction imbriquée"
      I18n.translate!("unknown.translation", default: "Hello").should eq "Hello"
      expect_raises(I18n::Errors::MissingTranslation, "missing translation: fr.unknown.translation") do
        I18n.translate!("unknown.translation")
      end
    end
  end

  describe "#t!" do
    it "is an alias for #translate!" do
      I18n.locale = "fr"

      I18n.t!("simple.translation").should eq "C'est une traduction simple"
      I18n.t!("splitted.translation").should eq "Ceci est une traduction définie séparément"
      I18n.t!("simple.interpolation", name: "John").should eq "Bonjour, John!"
      I18n.t!("simple.interpolation", {name: "John"}).should eq "Bonjour, John!"
      I18n.t!("simple.pluralization_and_interpolation", count: 6, name: "John").should eq "6 objets pour John!"
      I18n.t!("simple.pluralization", count: 5.5).should eq "5.5 objets"
      I18n.t!(:translation, scope: "simple.nested").should eq "C'est une traduction imbriquée"
      I18n.t!("unknown.translation", default: "Hello").should eq "Hello"
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

    it "returns a translation" do
      I18n.locale.should eq "en"

      (I18n.with_locale("fr") { I18n.t("simple.interpolation", name: "John") }).should eq "Bonjour, John!"

      I18n.locale.should eq "en"
    end

    it "raises if the locale is not part of the available locales" do
      expect_raises(I18n::Errors::InvalidLocale, "xy is not a valid locale") do
        I18n.with_locale("xy") do
        end
      end
    end
  end

  describe "#localize" do
    it "allows to localize datetimes and dates" do
      time = Time.utc(2016, 2, 15, 10, 20, 30)

      I18n.localize(time).should eq "Mon, 15 Feb 2016 10:20:30 +0000"
      I18n.localize(time, :short).should eq "15 Feb 10:20"
      I18n.localize(time, :long).should eq "February 15, 2016 10:20"
      I18n.localize(time, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"
      I18n.localize(time.date).should eq "2016-02-15"
      I18n.localize(time.date, :short).should eq "Feb 15"
      I18n.localize(time.date, :long).should eq "February 15, 2016"
      I18n.localize(time.date, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"

      I18n.locale = "fr"

      I18n.localize(time).should eq "15 février 2016 10h 20min 30s"
      I18n.localize(time, :short).should eq "15 fév. 10h20"
      I18n.localize(time, :long).should eq "lundi 15 février 2016 10h20"
      I18n.localize(time, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
      I18n.localize(time.date).should eq "15/02/2016"
      I18n.localize(time.date, :short).should eq "15 fév."
      I18n.localize(time.date, :long).should eq "15 février 2016"
      I18n.localize(time.date, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
    end

    it "allows to localize numbers" do
      I18n.localize(123_456).should eq "123,456"
      I18n.localize(123_456.789).should eq "123,456.789"
      I18n.localize(123_456.789, :custom).should eq "123,456.79"

      I18n.locale = "fr"

      I18n.localize(123_456).should eq "123 456"
      I18n.localize(123_456.789).should eq "123 456,789"
      I18n.localize(123_456.789, :custom).should eq "123 456,79"
    end
  end

  describe "#l" do
    it "is an alias for #localize" do
      time = Time.utc(2016, 2, 15, 10, 20, 30)

      I18n.l(time).should eq "Mon, 15 Feb 2016 10:20:30 +0000"
      I18n.l(time, :short).should eq "15 Feb 10:20"
      I18n.l(time, :long).should eq "February 15, 2016 10:20"
      I18n.l(time, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"
      I18n.l(time.date).should eq "2016-02-15"
      I18n.l(time.date, :short).should eq "Feb 15"
      I18n.l(time.date, :long).should eq "February 15, 2016"
      I18n.l(time.date, "%a, %d %b %Y").should eq "Mon, 15 Feb 2016"
      I18n.l(123_456).should eq "123,456"
      I18n.l(123_456.789).should eq "123,456.789"
      I18n.l(123_456.789, :custom).should eq "123,456.79"

      I18n.locale = "fr"

      I18n.l(time).should eq "15 février 2016 10h 20min 30s"
      I18n.l(time, :short).should eq "15 fév. 10h20"
      I18n.l(time, :long).should eq "lundi 15 février 2016 10h20"
      I18n.l(time, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
      I18n.l(time.date).should eq "15/02/2016"
      I18n.l(time.date, :short).should eq "15 fév."
      I18n.l(time.date, :long).should eq "15 février 2016"
      I18n.l(time.date, "%a, %d %b %Y").should eq "lun, 15 fév. 2016"
      I18n.l(123_456).should eq "123 456"
      I18n.l(123_456.789).should eq "123 456,789"
      I18n.l(123_456.789, :custom).should eq "123 456,79"
    end
  end
end
