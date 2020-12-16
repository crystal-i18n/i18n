module I18n
  module Loader
    class JSON < Base
      def initialize(@path : String)
      end

      def load : TranslationsHash
        raw_translations = [] of String

        Dir.glob(@path + "/**/*.json") do |filename|
          raw_translations << File.read(filename)
        end

        translations_data = TranslationsHash.new
        raw_translations.each do |data|
          ::JSON.parse(data).as_h.each do |locale, locale_data|
            translations_data[locale] ||= TranslationsHash.new
            translations_data[locale].as(TranslationsHash).merge!(parsed_data_to_translations_hash(locale_data))
          end
        end

        translations_data
      end

      private def parsed_data_to_translations_hash(data)
        translations = TranslationsHash.new

        data.as_h.each do |k, v|
          translations[k] = if v.as_s?
                              v.as_s
                            elsif v.as_a?
                              v.as_a.map(&.as_s)
                            else
                              parsed_data_to_translations_hash(v.clone)
                            end
        end

        translations
      end
    end
  end
end
