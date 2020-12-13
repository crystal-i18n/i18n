module I18n
  module Loader
    class YAML < Base
      def initialize(@path : String)
      end

      def load : TranslationsHash
        raw_translations = [] of String

        Dir.glob(@path + "/*.yml", @path + "/*.yaml") do |filename|
          raw_translations << File.read(filename)
        end

        translations_data = TranslationsHash.new
        raw_translations.each do |data|
          translations_data.merge!(parsed_data_to_translations_hash(::YAML.parse(data)))
        end

        translations_data
      end

      private def parsed_data_to_translations_hash(data)
        translations = TranslationsHash.new

        data.as_h.each do |k, v|
          translations[k.as_s] = if v.as_s?
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
