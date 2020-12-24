module I18n
  module Pluralization
    abstract class Rule
      # Breton pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Breton < Rule
        def apply(count : Float | Int) : Symbol
          mod10 = count % 10
          mod100 = count % 100

          if mod10 == 1 && ![11, 71, 91].includes?(mod100)
            :one
          elsif mod10 == 2 && ![12, 72, 92].includes?(mod100)
            :two
          elsif [3, 4, 9].includes?(mod10) && !((10..19).to_a + (70..79).to_a + (90..99).to_a).includes?(mod100)
            :few
          elsif count % 1_000_000 == 0 && count != 0
            :many
          else
            :other
          end
        end
      end
    end
  end
end
