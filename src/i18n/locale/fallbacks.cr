module I18n
  module Locale
    # A locales fallbacks configuration.
    #
    # This class allows to configure locales fallbacks. Locales fallbacks are comprised of a mapping of fallback chains
    # (where specific locales are associated with a specific fallback configuration) and a default fallback chain (which
    # is used when no fallback configurations are associated with specific locales).
    #
    # ```
    # I18n.config.fallbacks = I18n::Locale::Fallbacks.new(
    #   {"fr-CA-special": ["fr-CA", "fr", "en"]},
    #   default: ["en"]
    # )
    # ```
    class Fallbacks
      @default : Array(String)
      @mapping : Hash(String, Array(String))

      getter default
      getter mapping

      def initialize(
        mapping : Hash(String | Symbol, Array(String | Symbol) | String | Symbol) | NamedTuple | Nil = nil,
        default : Array(String | Symbol) | Nil = nil
      )
        @mapping = Hash(String, Array(String)).new
        if !mapping.nil?
          mapping.not_nil!.each do |k, v|
            @mapping[k.to_s] = v.is_a?(Array) ? v.map(&.to_s) : [v.to_s]
          end
        end

        @default = default.nil? ? Array(String).new : default.map(&.to_s)

        @computed = Hash(String, Array(String)).new
      end

      # Returns the locales that should be used as fallbacks for a given locale.
      def for(locale : String | Symbol) : Array(String)
        fallbacks = @computed[locale.to_s]?
        return fallbacks if !fallbacks.nil?

        @computed[locale.to_s] = gen_fallbacks_for([locale.to_s])
      end

      private def gen_fallbacks_for(tags, with_defaults = true, exclude = [] of String)
        fallbacks = [] of String

        fallbacks += tags.flat_map do |raw_tag|
          tag = Tag.new(raw_tag)
          tag_and_parents = ([tag] + tag.parents).map(&.to_s) - exclude
          tag_and_parents.each do |t|
            next if !@mapping.has_key?(t)
            tag_and_parents += gen_fallbacks_for(@mapping[t], false, exclude + tag_and_parents)
          end
          tag_and_parents
        end

        fallbacks += @default
        fallbacks.compact.uniq!
      end
    end
  end
end
