module I18n
  module Loader
    class YAML < Base
      def initialize(@path : String)
      end

      def load : TranslationsHash
        raw_translations = [] of String

        Dir.glob(@path + "/**/*.yml", @path + "/**/*.yaml") do |filename|
          raw_translations << File.read(filename)
        end

        translations_data = TranslationsHash.new
        raw_translations.each do |data|
          ::YAML.parse(data).as_h.each do |locale, locale_data|
            translations_data[locale.as_s] ||= TranslationsHash.new
            translations_data[locale.as_s].as(TranslationsHash).merge!(parsed_data_to_translations_hash(locale_data))
          end
        end

        translations_data
      end

      private def parsed_data_to_translations_hash(data)
        translations = TranslationsHash.new

        data.as_h.each do |k, v|
          translations[k.as_s] = if v.as_s?
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
