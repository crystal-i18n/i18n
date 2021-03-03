module I18n
  # The main I18n configuration class.
  #
  # This class holds all the configuration options of crystal-i18n. It is mainly used in order to initialize the global
  # catalog of translations (used in the context of `I18n#translate` for example) ; but it can also be used to
  # configure a custom catalog of translations through the use of the `I18n::Catalog#from_config` class method.
  class Config
    @available_locales : Array(String) | Nil
    @fallbacks : Locale::Fallbacks | Nil
    @normalized_translations : Catalog::NormalizedHash | Nil
    @translations_data : TranslationsHash | Nil

    # Returns the available locales.
    #
    # Unless explicitly set, the default value will be `nil`.
    getter available_locales

    # Returns the default locale.
    #
    # Unless explicitly set, the default locale will be `"en"`.
    getter default_locale

    # Returns the configured locale fallbacks.
    #
    # Unless explicitly set, the default value will be `nil`.
    getter fallbacks

    # Returns the array of configured translations loaders.
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
    getter loaders

    # Allows to set the array of configured translations loaders.
    #
    # Translations loaders will be used to populate the catalog of translations (`I18n::Catalog` object) that is
    # initialized from this configuration object. Translations loaders are subclasses of `I18n::Loader::Base` and are
    # used to extract raw translations from files (eg. yaml or json) or other sources.
    #
    # ```
    # I18n.config.loaders = [
    #   I18n::Loader::YAML.new("config/locales"),
    # ] of I18n::Loader::Base
    # ```
    setter loaders

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

    # Allows to set the locale fallbacks.
    #
    # Setting locale fallbacks will force catalogs of translations to try to lookup translations in other (configured)
    # locales if the current locale the translation is requested into is missing.
    #
    # The passed `fallback` can be a hash or a named tuple that defines the chains of fallbacks to use for specific
    # locales. For example:
    #
    # ```
    # I18n.config.fallbacks = {"en-CA" => ["en-US", "en"], "fr-CA" => "fr"}
    # ```
    #
    # It can also be a simple array of fallbacks. In that case, this chain of fallbacked locales will be used as a
    # default for all the available locales when translations are missing:
    #
    # ```
    # I18n.config.fallbacks = ["en-US", "en"]
    # ```
    #
    # It's also possible to specficy both default fallbacks and a mapping of fallbacks by initializing an
    # `I18n::Locale::Fallbacks` object as follows:
    #
    # ```
    # I18n.config.fallbacks = I18n::Locale::Fallbacks.new(
    #   {"fr-CA-special": ["fr-CA", "fr", "en"]},
    #   default: ["en"]
    # )
    # ```
    #
    # Finally, using `nil` in the context of this method will reset the configured fallbacks (and remove any previously
    # configured fallbacks).
    #
    # It's also important to always ensure that fallback locales are available locales: they should all be present in
    # the `#available_locales` array.
    def fallbacks=(
      fallbacks : Array(String | Symbol) |
                  Hash(String | Symbol, Array(String | Symbol) | String | Symbol) |
                  Locale::Fallbacks |
                  NamedTuple |
                  Nil
    )
      @fallbacks = case fallbacks
                   when Array
                     Locale::Fallbacks.new(default: fallbacks)
                   when Hash, NamedTuple
                     Locale::Fallbacks.new(mapping: fallbacks)
                   else
                     fallbacks
                   end
    end

    protected def normalized_translations : Catalog::NormalizedHash
      @normalized_translations ||= begin
        normalized_translations = Catalog::NormalizedHash.new
        Catalog.normalize_hash(translations_data, normalized_translations)
        normalized_translations
      end
    end

    protected def reset_translations_data : Nil
      @translations_data = nil
      @normalized_translations = nil
    end

    protected def translations_data : TranslationsHash
      @translations_data ||= begin
        tr_hash = TranslationsHash.new
        loaders.each do |loader|
          effective_translations = loader.load.select do |locale, _|
            available_locales.nil? || available_locales.not_nil!.empty? || available_locales.not_nil!.includes?(locale)
          end
          deep_merge_translations_hash(tr_hash, effective_translations)
        end
        tr_hash
      end
    end

    private def deep_merge_translations_hash(target, translations_hash)
      translations_hash.keys.each do |key|
        if !target[key]?
          target[key] = translations_hash[key]
          next
        end

        target_value = target[key]
        translations_hash_value = translations_hash[key]
        target[key] = if target_value.is_a?(Hash) && translations_hash_value.is_a?(Hash)
                        deep_merge_translations_hash(target_value, translations_hash_value)
                      else
                        translations_hash[key]
                      end
      end

      target
    end
  end
end
