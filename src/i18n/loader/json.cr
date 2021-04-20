module I18n
  module Loader
    # The JSON translations loader.
    #
    # This loader implementation allows to load translations from JSON files. It must be initialized from a given path
    # and it will recursively try to load all the JSON files that are available under the targetted directory:
    #
    # ```
    # I18n.config.loaders << I18n::Loader::JSON.new("config/locales")
    # ```
    #
    # This loader also allows to embed the raw translations that are available under the targetted directory inside the
    # compiled binary through the use of the `#embed` macro:
    #
    # ```
    # I18n.config.loaders << I18n::Loader::JSON.embed("config/locales")
    # ```
    class JSON < Base
      @path : String? = nil
      @preloaded_translations : TranslationsHash? = nil

      getter path
      getter preloaded_translations

      # Converts an array of JSON strings to a valid translations hash.
      def self.normalize_raw_translations(raw_translations : Array(String))
        translations_data = TranslationsHash.new

        raw_translations.each do |data|
          ::JSON.parse(data).as_h.each do |locale, locale_data|
            translations_data[locale] ||= TranslationsHash.new
            translations_data[locale].as(TranslationsHash).merge!(parsed_data_to_translations_hash(locale_data))
          end
        end

        translations_data
      end

      def initialize(@path : String)
      end

      def initialize(@preloaded_translations : TranslationsHash)
      end

      macro embed(path)
        {{ run("./json/embed", path) }}
      end

      def load : TranslationsHash
        return @preloaded_translations.not_nil! unless @preloaded_translations.nil?

        raw_translations = [] of String

        Dir.glob(@path.not_nil! + "/**/*.json") do |filename|
          raw_translations << File.read(filename)
        end

        self.class.normalize_raw_translations(raw_translations)
      end

      private def self.parsed_data_to_translations_hash(data)
        translations = TranslationsHash.new

        data.as_h.each do |k, v|
          translations[k] = if v.as_s?
                              v.as_s
                            elsif v.as_i?
                              v.as_i
                            elsif !v.as_bool?.nil?
                              v.as_bool
                            elsif v.as_a?
                              v.as_a.map(&.as_s)
                            elsif v.as_h?
                              parsed_data_to_translations_hash(v.clone)
                            else
                              v.as_nil
                            end
        end

        translations
      end
    end
  end
end
