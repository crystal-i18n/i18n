module I18n
  # The main I18n configuration class.
  #
  # This class holds all the configuration options of crystal-i18n. It is mainly used in order to initialize the global
  # catalog of translations (used in the context of `I18n#translate` for example) ; but it can also be used to
  # configure a custom catalog of translations through the use of the `I18n::Catalog#from_config` class method.
  class Config
    @available_locales : Array(String) | Nil

    # Returns the available locales.
    #
    # Unless explicitly set, the default value will be `nil`.
    getter available_locales

    # Returns the default locale.
    #
    # Unless explicitly set, the default locale will be `"en"`.
    getter default_locale

    def initialize
      @available_locales = nil
      @default_locale = Catalog::DEFAULT_LOCALE
      @loaders = Array(Loader::Base).new
    end

    # Allows to set the available locales.
    #
    # Setting available locales will force catalog of translations to only load and handle translations for the
    # specified set of locales. If an empty array or a `nil` value is passed to this method, then no restrictions will
    # be applied to the associated catalog of translations.
    def available_locales=(available_locales : Array(String | Symbol) | Nil)
      @available_locales = available_locales.nil? ? nil : available_locales.map(&.to_s)
    end

    # Allows to set the default locale.
    #
    # Unless explicitly set with this method, the default locale will be `"en"`.
    def default_locale=(locale : String | Symbol)
      @default_locale = locale.to_s
    end

    # Returns the list of configured translations loaders.
    #
    # Translations loaders will be used to populate the catalog of translations (`I18n::Catalog` object) that is
    # initialized from this configuration object. Translations loaders are subclasses of `I18n::Loader::Base` and are
    # used to extract raw translations from files (eg. yaml or json) or other sources.
    #
    # By default, an empty array will be returned by this method. Loaders have to be explicitly appended to this array
    # in order to be used to initialize associated catalog of translations. For example:
    #
    # ```
    # I18n.config.loaders << I18n::Loader::YAML.new("config/locales")
    # ```
    def loaders
      @loaders
    end
  end
end
