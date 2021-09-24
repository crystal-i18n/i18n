module I18n
  # A catalog of translations.
  #
  # Catalogs of translations hold all the translations for multiple locales and provide the ability to activate specific
  # locales in order to define in which locales the translated strings should be returned.
  class Catalog
    # :nodoc:
    alias NormalizedHash = Hash(String, Bool | Int32 | Nil | String)

    # The default locale that is considered when no other locales are configured nor activated.
    DEFAULT_LOCALE = "en"

    @available_locales : Array(String)
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
        default_locale: config.default_locale,
        available_locales: config.available_locales,
        fallbacks: config.fallbacks
      )

      catalog.inject_normalized(config.translations_data, config.normalized_translations)

      catalog
    end

    def initialize(
      @default_locale : String = DEFAULT_LOCALE,
      available_locales : Array(String) | Nil = nil,
      @fallbacks : Locale::Fallbacks | Nil = nil
    )
      @available_locales_restricted_to = available_locales.nil? ? [] of String : available_locales.not_nil!
      @available_locales = @available_locales_restricted_to.dup
      @locale = nil
      @translations = NormalizedHash.new
    end

    # Activates a locale for translations.
    #
    # This method allows to set the locale used to produce translated contents. Note that once activated, the current
    # locale will remain active until it's explicly changed again. `#with_locale` should be used instead of `#activate`
    # for cases where it is important to ensure that the previous active locale is restored.
    #
    # An `I18n::Errors::InvalidLocale` exception will be raised by this method if the passed locale is not available in
    # the catalog (ie. if no translations was injected into this catalog for the considered locale).
    def activate(locale : String | Symbol) : String
      raise_if_locale_not_available(locale)
      @locale = locale.to_s
    end

    # Returns the available locales for the catalog.
    #
    # If no translations have injected into the catalog of translations yet, an array with the default locale in it will
    # be returned.
    def available_locales : Array(String)
      @available_locales.empty? ? [default_locale] : @available_locales
    end

    # Injects the hash of translations returned by a specific loader.
    def inject(loader : Loader::Base) : Nil
      inject(loader.load)
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
      effective_translations = translations.select do |locale, _|
        @available_locales_restricted_to.empty? || @available_locales_restricted_to.includes?(locale)
      end

      self.class.normalize_hash(effective_translations, @translations)

      translations.keys.each do |locale|
        @available_locales << locale if !@available_locales.includes?(locale)
      end
    end

    # Alias for `#localize`.
    def l(object : Number, format : String | Symbol = :default) : String
      localize(object, format)
    end

    # Alias for `#localize`.
    def l(
      object : Time | Tuple(Int32, Int32, Int32),
      format : String | Symbol = :default,
      **kwargs
    ) : String
      localize(object, format, **kwargs)
    end

    # Returns the currently active locale.
    #
    # The returned value will default to the default locale unless another locale is explicitly activated.
    def locale : String
      @locale ||= @default_locale
    end

    # Alias for `#activate`.
    def locale=(locale : String | Symbol) : String
      activate(locale)
    end

    # Localizes a number.
    #
    # This method allows to localize a `Number` object (such as an integer or a float). By default, the `:default`
    # format is used:
    #
    # ```
    # I18n.localize(123_456.789) # => 123,456.789
    # ```
    #
    # Custom formats can be used as well, for example:
    #
    # ```
    # I18n.localize(123_456.789, :custom) # => 123,456.79
    # ```
    #
    # This method requires the following structure to be defined in localization files (the following example uses YAML,
    # but this can be easily applied to JSON files too):
    #
    # ```
    # en:
    #   i18n:
    #     number:
    #       formats:
    #         default:
    #           delimiter: ","
    #           separator: "."
    #           decimal_places: 3
    #           group: 3
    #           only_significant: false
    # ````
    #
    # Custom formats can be defined under `i18n.number.formats` in order to use other combinations of delimiters,
    # separators, decimal places, etc.
    def localize(object : Number, format : String | Symbol = :default) : String
      separator = fetch_translation(locale, "i18n.number.formats.#{format}.separator")
      delimiter = fetch_translation(locale, "i18n.number.formats.#{format}.delimiter")
      decimal_places = fetch_translation(locale, "i18n.number.formats.#{format}.decimal_places")
      group = fetch_translation(locale, "i18n.number.formats.#{format}.group")
      only_significant = fetch_translation(locale, "i18n.number.formats.#{format}.only_significant")

      object.format(
        separator: separator.as?(String) || '.',
        delimiter: delimiter.as?(String) || ',',
        decimal_places: decimal_places.as?(Int32),
        group: group.as?(Int32) || 3,
        only_significant: only_significant.as?(Bool) || false,
      )
    end

    # Localizes a datetime or a date.
    #
    # This method allows to localize a `Time` object or a `Tuple(Int32, Int32, Int32)` object (which correspond to a
    # date obtained through the use of `Time#date`). Both time or "date" objects can be localized using a predefined
    # format such as `:default`, `:short` or `:long`:
    #
    # ```
    # I18n.localize(Time.local)             # => Sun, 13 Dec 2020 21:11:08 -0500
    # I18n.localize(Time.local, :short)     # => 13 Dec 21:11
    # I18n.localize(Time.local.date)        # => 2020-12-13
    # I18n.localize(Time.local.date, :long) # => December 13, 2020
    # ```
    #
    # Custom format strings can be specified too. For example:
    #
    # ```
    # I18n.localize(Time.local, "%a, %d %b %Y") # => Sun, 13 Dec 2020
    # ```
    #
    # This method requires the following structure to be defined in localization files (the following example uses YAML,
    # but this can easily be applied to JSON files too):
    #
    # ```
    # en:
    #   i18n:
    #     date:
    #       abbr_day_names: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
    #       abbr_month_names: [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
    #       day_names: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
    #       month_names: [January, February, March, April, May, June,
    #                     July, August, September, October, November, December]
    #       formats:
    #         default: "%Y-%m-%d"
    #         long: "%B %d, %Y"
    #         short: "%b %d"
    #     time:
    #       am: am
    #       formats:
    #         default: "%a, %d %b %Y %H:%M:%S %z"
    #         long: "%B %d, %Y %H:%M"
    #         short: "%d %b %H:%M"
    #       pm: pm
    # ```
    def localize(
      object : Time | Tuple(Int32, Int32, Int32),
      format : String | Symbol = :default,
      **kwargs
    ) : String
      type = object.is_a?(Time) ? "time" : "date"
      format = begin
        t!("i18n.#{type}.formats.#{format}", **kwargs)
      rescue Errors::MissingTranslation
        format
      end

      object = Time.local(year: object[0], month: object[1], day: object[2]) if !object.is_a?(Time)

      format = format.to_s.gsub(/%(|\^)[aAbBpP]/) do |match|
        case match
        when "%a"  then t!("i18n.date.abbr_day_names.#{object.day_of_week.to_i - 1}")
        when "%^a" then t!("i18n.date.abbr_day_names.#{object.day_of_week.to_i - 1}").upcase
        when "%A"  then t!("i18n.date.day_names.#{object.day_of_week.to_i - 1}")
        when "%^A" then t!("i18n.date.day_names.#{object.day_of_week.to_i - 1}").upcase
        when "%b"  then t!("i18n.date.abbr_month_names.#{object.month - 1}")
        when "%^b" then t!("i18n.date.abbr_month_names.#{object.month - 1}").upcase
        when "%B"  then t!("i18n.date.month_names.#{object.month - 1}")
        when "%^B" then t!("i18n.date.month_names.#{object.month - 1}").upcase
        when "%p"  then t!("i18n.time.#{object.hour < 12 ? :am : :pm}").upcase
        when "%P"  then t!("i18n.time.#{object.hour < 12 ? :am : :pm}").downcase
        end
      end

      object.to_s(format)
    end

    # Alias for `#translate`.
    def t(
      key : String | Symbol,
      params : Hash | NamedTuple | Nil = nil,
      count : Float | Int | Nil = nil,
      scope : Array(String | Symbol) | String | Symbol | Nil = nil,
      default = nil,
      **kwargs
    ) : String
      translate(key, params, count, scope, default, **kwargs)
    end

    # Alias for `#translate!`.
    def t!(
      key : String | Symbol,
      params : Hash | NamedTuple | Nil = nil,
      count : Float | Int | Nil = nil,
      scope : Array(String | Symbol) | String | Symbol | Nil = nil,
      default = nil,
      **kwargs
    ) : String
      translate!(key, params, count, scope, default, **kwargs)
    end

    # Performs a translation lookup.
    #
    # This method performs a translation lookup for a given `key`. If no translation can be found for the given `key`, a
    # default string stating that the translation is missing will be returned.
    #
    # ```
    # catalog.translate("simple.translation")               # => "Simple translation"
    # catalog.translate("hello.user", name: "John")         # => "Hello John!"
    # catalog.translate(:blank, scope: "error.username")    # => "Username cannot be blank"
    # catalog.translate(:blank, scope: [:error, :username]) # => "Username cannot be blank"
    # ```
    def translate(
      key : String | Symbol,
      params : Hash | NamedTuple | Nil = nil,
      count : Float | Int | Nil = nil,
      scope : Array(String | Symbol) | String | Symbol | Nil = nil,
      default = nil,
      **kwargs
    ) : String
      translate!(key, params, count, scope, default, **kwargs)
    rescue error : Errors::MissingTranslation
      error.message.to_s
    end

    # Performs a translation lookup.
    #
    # This method performs a translation lookup for a given `key`. If no translation can be found for the given `key`,
    # an `I18n::Errors::MissingTranslation` exception will be raised.
    #
    # ```
    # catalog.translate!("simple.translation")               # => "Simple translation"
    # catalog.translate!("hello.user", name: "John")         # => "Hello John!"
    # catalog.translate!(:blank, scope: "error.username")    # => "Username cannot be blank"
    # catalog.translate!(:blank, scope: [:error, :username]) # => "Username cannot be blank"
    # ```
    def translate!(
      key : String | Symbol,
      params : Hash | NamedTuple | Nil = nil,
      count : Float | Int | Nil = nil,
      scope : Array(String | Symbol) | String | Symbol | Nil = nil,
      default = nil,
      **kwargs
    ) : String
      if scope.is_a?(Array)
        key = scope.reverse.reduce(key) { |k, part| suffix_key(part.to_s, k) }
      elsif !scope.nil?
        key = suffix_key(scope.to_s, key)
      end

      entry = fetch_translation!(locale, key, count: count, default: default).not_nil!.to_s

      entry = interpolate(entry, "count", count) unless count.nil?

      if !params.nil?
        params.each do |variable_name, value|
          entry = interpolate(entry, variable_name, value)
        end
      end

      kwargs.each do |variable_name, value|
        entry = interpolate(entry, variable_name, value)
      end

      entry
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
    #
    # An `I18n::Errors::InvalidLocale` exception will be raised by this method if the passed locale is not available in
    # the catalog (ie. if no translations was injected into this catalog for the considered locale).
    def with_locale(locale : String | Symbol)
      current_locale = @locale
      self.locale = locale
      yield
    ensure
      self.locale = current_locale || default_locale
    end

    protected def self.normalize_hash(
      translations : TranslationsHash,
      normalized : NormalizedHash,
      path : String = ""
    )
      translations.each do |key, data|
        current_path = path.empty? ? key : suffix_key(path, key)

        case data
        in Bool, Int32, Nil, String
          normalized[current_path] = data
        in Array(String)
          data.each_with_index do |value, i|
            normalized[suffix_key(current_path, i)] = value
          end
        in TranslationsHash, Hash(String, Hash(String, String)), Hash(String, String)
          normalize_hash(data, normalized, current_path)
        end
      end

      normalized
    end

    protected def self.suffix_key(key, suffix)
      "#{key}.#{suffix}"
    end

    protected def inject_normalized(data : TranslationsHash, normalized : NormalizedHash)
      @translations = normalized

      data.keys.each do |locale|
        @available_locales << locale if !@available_locales.includes?(locale)
      end
    end

    private def fetch_translation(locale, key, count = nil, default = nil, ongoing_fallback = false)
      fetch_translation!(locale, key, count, default, ongoing_fallback)
    rescue error : Errors::MissingTranslation
      nil
    end

    private def fetch_translation!(locale, key, count = nil, default = nil, ongoing_fallback = false)
      full_key = suffix_key(locale, key)
      full_key = pluralized_key(full_key, count) unless count.nil?

      result = if @fallbacks.nil? || ongoing_fallback
                 @translations[full_key]?
               else
                 @fallbacks.not_nil!.for(locale).each do |fallback|
                   r = fetch_translation(fallback, key, count: count, default: default, ongoing_fallback: true)
                   break r if !r.nil?
                 end
               end

      return result if !result.nil? || ongoing_fallback

      default.nil? ? raise Errors::MissingTranslation.new("missing translation: #{full_key}") : default
    end

    private def interpolate(translation, variable_name, value)
      translation.gsub(/\%{#{variable_name}}/, value)
    end

    private def locale_available?(locale)
      available_locales.includes?(locale.to_s)
    end

    private def pluralized_key(prefix, count)
      suffix = if count == 0 && @translations[suffix_key(prefix, :zero)]?
                 :zero
               elsif !(rule = Pluralization.rule_for(locale)).nil?
                 rule.apply(count)
               else
                 count == 1 ? :one : :other
               end

      suffix_key(prefix, suffix)
    end

    private def raise_if_locale_not_available(locale)
      raise Errors::InvalidLocale.new("#{locale} is not a valid locale") if !locale_available?(locale)
    end

    private def suffix_key(key, suffix)
      self.class.suffix_key(key, suffix)
    end
  end
end
