module I18n
  module Pluralization
    abstract class Rule
      # Irish pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Irish < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1
            :one
          elsif count == 2
            :two
          elsif FROM_3_TO_6.includes?(count)
            :few
          elsif FROM_7_TO_10.includes?(count)
            :many
          else
            :other
          end
        end

        private FROM_3_TO_6  = (3..6).to_a
        private FROM_7_TO_10 = (7..10).to_a
      end
    end
  end
end
