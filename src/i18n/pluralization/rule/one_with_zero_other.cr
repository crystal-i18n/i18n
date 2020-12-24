module I18n
  module Pluralization
    abstract class Rule
      # Pluralization rule used for: Akan, Amharic, Bihari, Filipino, guw, Hindi, Lingala, Malagasy, Northen Sotho,
      # Tachelhit, Tagalog, Tigrinya, Walloon.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class OneWithZeroOther < Rule
        def apply(count : Float | Int) : Symbol
          count == 0 || count == 1 ? :one : :other
        end
      end
    end
  end
end
