module I18n
  module Locale
    # A locale tag.
    #
    # This class allows to manipulate locale tags and locale tag parents.
    class Tag
      @parts : Array(String)?

      def initialize(@tag : String)
      end

      def ==(other : self)
        super || other.to_s == @tag
      end

      # Returns the direct parent tag or `nil` if none is available.
      def parent : self?
        parts.size > 1 ? self.class.new(parts[0..(parts.size - 2)].join("-")) : nil
      end

      # Returns all the available parent tags for the considered locale tags.
      #
      # An empty array is returned if the considered locale tags does not have any parents.
      def parents : Array(self)
        parents = [] of Tag?
        parents << parent
        parents += parents[0].not_nil!.parents if !parents[0].nil?
        parents.compact
      end

      def to_s
        @tag
      end

      private def parts
        @parts ||= @tag.split("-")
      end
    end
  end
end
