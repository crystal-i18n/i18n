module I18n
  module Pluralization
    abstract class Rule
      # The default pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class OneOther < Rule
        def apply(count : Float | Int) : Symbol
          count == 1 ? :one : :other
        end
      end
    end
  end
end
