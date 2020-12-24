module I18n
  module Pluralization
    abstract class Rule
      # Manx pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Manx < Rule
        def apply(count : Float | Int) : Symbol
          if [1, 2].includes?(count % 10) || count % 20 == 0
            :one
          else
            :other
          end
        end
      end
    end
  end
end
