module I18n
  module Pluralization
    abstract class Rule
      # Pluralization rule used for: Czech, Slovak.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class WestSlavic < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1
            :one
          elsif FROM_2_TO_4.includes?(count)
            :few
          else
            :other
          end
        end

        private FROM_2_TO_4 = (2..4).to_a
      end
    end
  end
end
