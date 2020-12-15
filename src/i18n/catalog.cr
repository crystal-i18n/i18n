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
      count : Int? = nil,
      scope : Array(String | Symbol) | String | Symbol | Nil = nil,
      **kwargs
    ) : String
      translate(key, count, scope, **kwargs)
    end

    # Alias for `#translate!`.
    def t!(
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
    # catalog.translate("simple.translation")               # => "Simple translation"
    # catalog.translate("hello.user", name: "John")         # => "Hello John!"
    # catalog.translate(:blank, scope: "error.username")    # => "Username cannot be blank"
    # catalog.translate(:blank, scope: [:error, :username]) # => "Username cannot be blank"
    # ```
    def translate(
      key : String | Symbol,
      count : Int? = nil,
      scope : Array(String | Symbol) | String | Symbol | Nil = nil,
      **kwargs
    ) : String
      translate!(key, count, scope, **kwargs)
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
      count : Int? = nil,
      scope : Array(String | Symbol) | String | Symbol | Nil = nil,
      **kwargs
    ) : String
      if scope.is_a?(Array)
        key = scope.reverse.reduce(key) { |k, part| suffix_key(part.to_s, k) }
      elsif !scope.nil?
        key = suffix_key(scope.to_s, key)
      end

      key = suffix_key(locale, key)
      key = pluralized_key(key, count) unless count.nil?

      entry = @translations.fetch(key) { raise Errors::MissingTranslation.new("missing translation: #{key}") }

      entry = interpolate(entry, "count", count) unless count.nil?
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
    def with_locale(locale : String | Symbol) : Nil
      current_locale = @locale
      self.locale = locale
      yield
    ensure
      self.locale = current_locale || default_locale
    end

    private def inject_and_normalize(translations : TranslationsHash, path : String = "")
      translations.each do |key, data|
        current_path = path.empty? ? key : suffix_key(path, key)

        if data.is_a?(String)
          @translations[current_path] = data
        elsif data.is_a?(Array)
          data.each_with_index do |value, i|
            @translations[suffix_key(current_path, i)] = value
          end
        else
          inject_and_normalize(data, current_path)
        end
      end
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
      "#{key}.#{suffix}"
    end
  end
end
