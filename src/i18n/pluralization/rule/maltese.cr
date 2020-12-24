module I18n
  module Pluralization
    abstract class Rule
      # Maltese pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Maltese < Rule
        def apply(count : Float | Int) : Symbol
          mod100 = count % 100

          if count == 1
            :one
          elsif count == 0 || FROM_2_TO_10.includes?(mod100)
            :few
          elsif FROM_11_TO_19.includes?(mod100)
            :many
          else
            :other
          end
        end

        private FROM_2_TO_10  = (2..10).to_a
        private FROM_11_TO_19 = (11..19).to_a
      end
    end
  end
end
