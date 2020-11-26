require "json"
require "yaml"

require "./i18n/**"

module I18n
  alias TranslationsHashValues = String | Hash(String, TranslationsHashValues)
  alias TranslationsHash = Hash(String, TranslationsHashValues)

  @@config : Config?
  @@catalog : Catalog?

  def self.activate(locale : String | Symbol) : String
    catalog.activate(locale)
  end

  def self.config : Config
    @@config ||= Config.new
  end

  def self.config=(config : Config) : Config
    @@config = config
  end

  def self.init : Nil
    @@catalog = Catalog.from_config(config)
  end

  def self.locale : String
    catalog.locale
  end

  def self.locale=(locale : String | Symbol) : String
    catalog.activate(locale)
  end

  def self.t(key : String | Symbol, count : Int? = nil, **kwargs) : String
    translate(key, count, **kwargs)
  end

  def self.t!(key : String | Symbol, count : Int? = nil, **kwargs) : String
    translate!(key, count, **kwargs)
  end

  def self.translate(key : String | Symbol, count : Int? = nil, **kwargs) : String
    catalog.translate(key, count, **kwargs)
  end

  def self.translate!(key : String | Symbol, count : Int? = nil, **kwargs) : String
    catalog.translate!(key, count, **kwargs)
  end

  def self.with_locale(locale : String | Symbol) : Nil
    catalog.with_locale(locale)
  end

  private def self.catalog
    @@catalog ||= Catalog.new
  end
end
