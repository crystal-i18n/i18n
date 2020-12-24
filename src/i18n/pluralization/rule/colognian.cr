module I18n
  module Pluralization
    abstract class Rule
      # Colognian pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Colognian < Rule
        def apply(count : Float | Int) : Symbol
          if count == 0
            :zero
          elsif count == 1
            :one
          else
            :other
          end
        end
      end
    end
  end
end
