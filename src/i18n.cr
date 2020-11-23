require "json"
require "yaml"

require "./i18n/**"

module I18n
  # :nodoc:
  alias FiberId = UInt64

  alias TranslationsHashValues = String | Hash(String, TranslationsHashValues)
  alias TranslationsHash = Hash(String, TranslationsHashValues)

  @@config = {} of FiberId => Config
  @@catalog = {} of FiberId => Catalog

  def self.activate(locale : String | Symbol) : String
    catalog.activate(locale)
  end

  def self.config
    @@config[Fiber.current.object_id] ||= Config.new
  end

  def self.init : Nil
    @@catalog[Fiber.current.object_id] = Catalog.from_config(config)
  end

  def self.locale : String
    catalog.locale
  end

  def self.locale=(locale : String | Symbol) : String
    catalog.activate(locale)
  end

  def self.t(key : String | Symbol) : String
    translate(key)
  end

  def self.t!(key : String | Symbol) : String
    translate(key)
  end

  def self.translate(key : String | Symbol) : String
    catalog.translate(key)
  end

  def self.translate!(key : String | Symbol) : String
    catalog.translate!(key)
  end

  def self.with_locale(locale : String | Symbol) : Nil
    catalog.with_locale(locale)
  end

  private def self.catalog
    @@catalog[Fiber.current.object_id] ||= Catalog.new
  end
end
