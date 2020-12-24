module I18n
  module Pluralization
    abstract class Rule
      # Latvian pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Latvian < Rule
        def apply(count : Float | Int) : Symbol
          if count % 10 == 1 && count % 100 != 11
            :one
          else
            :other
          end
        end
      end
    end
  end
end
