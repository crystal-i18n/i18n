module I18n
  module Loader
    class JSON < Base
      def initialize(@path : String)
      end

      def load : TranslationsHash
        raw_translations = [] of String

        Dir.glob(@path + "/*.json") do |filename|
          raw_translations << File.read(filename)
        end

        translations_data = TranslationsHash.new
        raw_translations.each do |data|
          translations_data.merge!(parsed_data_to_translations_hash(::JSON.parse(data)))
        end

        translations_data
      end

      private def parsed_data_to_translations_hash(data)
        translations = TranslationsHash.new

        data.as_h.each do |k, v|
          translations[k] = v.as_s? ? v.as_s : parsed_data_to_translations_hash(v.clone)
        end

        translations
      end
    end
  end
end
