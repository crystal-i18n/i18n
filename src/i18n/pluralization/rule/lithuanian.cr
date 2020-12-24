module I18n
  module Pluralization
    abstract class Rule
      # Lithuanian pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Lithuanian < Rule
        def apply(count : Float | Int) : Symbol
          mod10 = count % 10
          mod100 = count % 100

          if mod10 == 1 && !FROM_11_TO_19.includes?(mod100)
            :one
          elsif FROM_2_TO_9.includes?(mod10) && !FROM_11_TO_19.includes?(mod100)
            :few
          else
            :other
          end
        end

        private FROM_2_TO_9   = (2..9).to_a
        private FROM_11_TO_19 = (11..19).to_a
      end
    end
  end
end
