module I18n
  module Pluralization
    abstract class Rule
      # Langi pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Langi < Rule
        def apply(count : Float | Int) : Symbol
          if count == 0
            :zero
          elsif count > 0 && count < 2
            :one
          else
            :other
          end
        end
      end
    end
  end
end
