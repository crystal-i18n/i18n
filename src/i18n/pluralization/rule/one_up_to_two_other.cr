module I18n
  module Pluralization
    abstract class Rule
      # Pluralization rule used for: French, Fulah, Kabyle.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class OneUpToTwoOther < Rule
        def apply(count : Float | Int) : Symbol
          count && count >= 0 && count < 2 ? :one : :other
        end
      end
    end
  end
end
