module I18n
  # A catalog of translations.
  #
  # Catalogs of translations hold all the translations for multiple locales and provide the ability to activate specific
  # locales in order to define in which locales the translated strings should be returned.
  class Catalog
    # The default locale that is considered when no other locales are configured nor activated.
    DEFAULT_LOCALE = "en"

    @locale : String?

    # Returns the default locale used by the catalog.
    getter default_locale

    # Returns the locale currently activated for the catalog.
    #
    # Unless a locale is explicitly activated, this will default to `"en"`.
    getter locale

    # Initializes a new catalog from a specific configuration object.
    #
    # This class methods provides the ability to initialize a new catalog of translation from an existing `I18n::Config`
    # object: all the configuration options set on this object will be used to intialize the new catalog of
    # translations.
    def self.from_config(config : Config) : self
      catalog = new(
        default_locale: config.default_locale
      )

      config.loaders.each do |loader|
        catalog.inject(loader.load)
      end

      catalog
    end

    def initialize(
      @default_locale : String = DEFAULT_LOCALE
    )
      @available_locales = [] of String
      @locale = nil
      @translations = {} of String => String
    end

    # Activates a locale for translations.
    #
    # This method allows to set the locale used to produce translated contents. Note that once activated, the current
    # locale will remain active until it's explicly changed again. `#with_locale` should be used instead of `#activate`
    # for cases where it is important to ensure that the previous active locale is restored.
    def activate(locale : String | Symbol) : String
      raise_if_locale_not_available(locale)
      @locale = locale.to_s
    end

    # Injects a hash of translations into the catalog.
    #
    # This method can be used to inject a hash of loaded translations into a specific catalog. This is mainly useful if
    # a custom catalog is created manually:
    #
    # ```
    # loader = I18n::Loader::YAML.new("config/locales")
    # catalog = I18n::Catalog.new
    # catalog.inject(loader.load)
    # ```
    def inject(translations : TranslationsHash) : Nil
      inject_and_normalize(translations)
      translations.keys.each do |locale|
        @available_locales << locale
      end
    end

    # Returns the currently active locale.
    #
    # The returned value will default to the default locale another locale is explicitly activated.
    def locale : String
      @locale ||= @default_locale
    end

    # Alias for `#activate`.
    def locale=(locale : String | Symbol) : String
      activate(locale)
    end

    # Alias for `#translate`.
    def t(key : String | Symbol) : String
      translate(key)
    end

    # Alias for `#translate!`.
    def t!(key : String | Symbol) : String
      translate(key)
    end

    # Performs a translation lookup.
    #
    # This method performs a translation lookup for a given `key`. If no translation can be found for the given `key`, a
    # default string stating that the translation is missing will be returned.
    def translate(key : String | Symbol) : String
      translate!(key)
    rescue error : Errors::MissingTranslation
      error.message.to_s
    end

    # Performs a translation lookup.
    #
    # This method performs a translation lookup for a given `key`. If no translation can be found for the given `key`,
    # an `I18n::Errors::MissingTranslation` exception will be raised.
    def translate!(key : String | Symbol) : String
      translation_key = "#{locale}.#{key}"
      @translations.fetch(translation_key) { raise Errors::MissingTranslation.new("missing translation: #{key}") }
    end

    # Allows to activate a specific locale for a specific block.
    #
    # This method allows to activate a specific locale for a specific block, ensuring that the change of locale does not
    # leak outside of the block. When the block execution completes, the locale that was previously activated prior to
    # the block execution will be automatically activated again:
    #
    # ```
    # catalog = I18n::Catalog.new(default_locale: "en")
    # catalog.with_locale(:es) do
    #   catalog.translate!("test.translation") # outputs a spanish translation
    # end
    # catalog.translate!("test.translation") # outputs an english translation
    # ```
    def with_locale(locale : String | Symbol) : Nil
      current_locale = @locale
      self.locale = locale
      yield
    ensure
      self.locale = current_locale
    end

    private def inject_and_normalize(translations : TranslationsHash, path : String = "")
      translations.each do |key, data|
        current_path = path.empty? ? key : "#{path}.#{key}"

        if data.is_a?(String)
          @translations[current_path] = data
        else
          inject_and_normalize(data, current_path)
        end
      end
    end

    private def locale_available?(locale)
      available_locales.includes?(locale.to_s)
    end

    private def raise_if_locale_not_available(locale)
      raise InvalidLocale.new("#{locale} is not a valid locale") if !locale_available?(locale)
    end
  end
end
