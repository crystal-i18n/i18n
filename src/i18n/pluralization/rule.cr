module I18n
  module Pluralization
    # Abstract pluralization rule.
    #
    # A pluralization rule class provides a main `#rule` method that, given a `count` number, returns the corresponding
    # plural catagory tag. Ideally returned values should be part of the common plural category tags that are defined
    # [by the CLDR](http://cldr.unicode.org/index/cldr-spec/plural-rules) (`:zero`, `:one`, `:two`, `:few`, `:many` and
    # `:other`).
    abstract class Rule
      abstract def apply(count : Float | Int) : Symbol
    end
  end
end
