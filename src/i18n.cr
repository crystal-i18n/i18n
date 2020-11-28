require "json"
require "yaml"

require "./i18n/**"

# The I18n module provides a simple interface for internationalization and localization.
#
# ### Basic setup
#
# Assuming that a `config/locales` relative folder exists, with the following `en.yml` file in it:
#
# ```
# en:
#   simple:
#     translation: "This is a simple translation"
#     interpolation: "Hello, %{name}!"
#     pluralization:
#       one: "One item"
#       other: "%{count} items"
# ```
#
# The following I18n setup could be defined:
#
# ```
# require "i18n"
#
# I18n.config.loaders << I18n::Loader::YAML.new("config/locales")
# I18n.init
# ```
#
# ### Translations lookups
#
# Translations can be resolved using the `#translate` method (or the shorter version `#t`) and the `#translate!` method
# (or the shorter version `#t!`):
#
# ```
# I18n.t("simple.translation")                     # outputs "This is a simple translation"
# I18n.t("simple.interpolation", name: "John Doe") # outputs "Hello, John Doe!"
# I18n.t("simple.pluralization", count: 42)        # outputs "42 items"
# ```
module I18n
  alias TranslationsHashValues = String | Hash(String, TranslationsHashValues)
  alias TranslationsHash = Hash(String, TranslationsHashValues)

  @@config : Config?
  @@catalog : Catalog?

  # Activates a locale for translations.
  #
  # This method allows to set the locale used to produce translated contents. Note that once activated, the current
  # locale will remain active until it's explicly changed again. `#with_locale` should be used instead of `#activate`
  # for cases where it is important to ensure that the previous active locale is restored.
  #
  # An `I18n::Errors::InvalidLocale` exception will be raised by this method if the passed locale is not available in
  # the main catalog of translations (ie. if no translations were defined for the considered locale).
  def self.activate(locale : String | Symbol) : String
    catalog.activate(locale)
  end

  # Returns the available locales.
  #
  # If no translations have been loaded yet, an array with the default locale in it will be returned.
  def self.available_locales : Array(String)
    catalog.available_locales
  end

  # Returns the main configuration object.
  #
  # This methods return the main `I18n::Config` object used by the `I18n` module to persist configuration options.
  def self.config : Config
    @@config ||= Config.new
  end

  # Allows to replace the main configuration object.
  #
  # This method will replace the main configuration object used by the `I18n` module but will not change the main
  # catalog of translation. Calling `#init` once the new `I18n::Config` object has been assigned might be necessary in
  # order to ensure that the main catalog of translations used by the `I18n` module is reinitialized.
  def self.config=(config : Config) : Config
    @@config = config
  end

  # Initializes the `I18n` module.
  #
  # Calling this method at application startup is necessary in order to ensure that the configuration options that were
  # set through the use of the `I18n::Config` object (returned by the `#config` method) are read in order to initialize
  # the main catalog of translations. Calling this will ensure that the translations files that were defined using
  # `I18n::Config#loaders` are read and processed in order to allow further translations lookups.
  def self.init : Nil
    @@catalog = Catalog.from_config(config)
  end

  # Returns the currently active locale.
  #
  # The returned value will default to the default locale unless another locale is explicitly activated.
  def self.locale : String
    catalog.locale
  end

  # Alias for `#activate`.
  def self.locale=(locale : String | Symbol) : String
    catalog.activate(locale)
  end

  # Alias for `#translate`.
  def self.t(
    key : String | Symbol,
    count : Int? = nil,
    scope : Array(String | Symbol) | String | Symbol | Nil = nil,
    **kwargs
  ) : String
    translate(key, count, scope, **kwargs)
  end

  # Alias for `#translate!`.
  def self.t!(
    key : String | Symbol,
    count : Int? = nil,
    scope : Array(String | Symbol) | String | Symbol | Nil = nil,
    **kwargs
  ) : String
    translate!(key, count, scope, **kwargs)
  end

  # Performs a translation lookup.
  #
  # This method performs a translation lookup for a given `key`. If no translation can be found for the given `key`, a
  # default string stating that the translation is missing will be returned.
  #
  # ```
  # I18n.translate("simple.translation")               # => "Simple translation"
  # I18n.translate("hello.user", name: "John")         # => "Hello John!"
  # I18n.translate(:blank, scope: "error.username")    # => "Username cannot be blank"
  # I18n.translate(:blank, scope: [:error, :username]) # => "Username cannot be blank"
  # ```
  def self.translate(
    key : String | Symbol,
    count : Int? = nil,
    scope : Array(String | Symbol) | String | Symbol | Nil = nil,
    **kwargs
  ) : String
    catalog.translate(key, count, scope, **kwargs)
  end

  # Performs a translation lookup.
  #
  # This method performs a translation lookup for a given `key`. If no translation can be found for the given `key`,
  # an `I18n::Errors::MissingTranslation` exception will be raised.
  #
  # ```
  # I18n.translate!("simple.translation")               # => "Simple translation"
  # I18n.translate!("hello.user", name: "John")         # => "Hello John!"
  # I18n.translate!(:blank, scope: "error.username")    # => "Username cannot be blank"
  # I18n.translate!(:blank, scope: [:error, :username]) # => "Username cannot be blank"
  # ```
  def self.translate!(
    key : String | Symbol,
    count : Int? = nil,
    scope : Array(String | Symbol) | String | Symbol | Nil = nil,
    **kwargs
  ) : String
    catalog.translate!(key, count, scope, **kwargs)
  end

  # Allows to activate a specific locale for a specific block.
  #
  # This method allows to activate a specific locale for a specific block, ensuring that the change of locale does not
  # leak outside of the block. When the block execution completes, the locale that was previously activated prior to the
  # block execution will be automatically activated again:
  #
  # ```
  # I18n.config.default_locale # outputs "en"
  # I18n.with_locale(:es) do
  #   I18n.translate!("test.translation") # outputs a spanish translation
  # end
  # I18n.translate!("test.translation") # outputs an english translation
  # ```
  #
  # An `I18n::Errors::InvalidLocale` exception will be raised by this method if the passed locale is not available in
  # (ie. if no translations were defined for this locale).
  def self.with_locale(locale : String | Symbol, &block) : Nil
    catalog.with_locale(locale, &block)
  end

  private def self.catalog
    @@catalog ||= Catalog.new
  end
end
