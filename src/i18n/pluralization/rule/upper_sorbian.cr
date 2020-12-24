module I18n
  module Pluralization
    abstract class Rule
      # Upper sorbian pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class UpperSorbian < Rule
        def apply(count : Float | Int) : Symbol
          mod100 = count % 100

          if mod100 == 1
            :one
          elsif mod100 == 2
            :two
          elsif mod100 == 3 || mod100 == 4
            :few
          else
            :other
          end
        end
      end
    end
  end
end
