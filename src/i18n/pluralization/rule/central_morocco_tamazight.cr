module I18n
  module Pluralization
    abstract class Rule
      # Central Morocco Tamazight pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class CentralMoroccoTamazight < Rule
        def apply(count : Float | Int) : Symbol
          if ([0, 1] + (11..99).to_a).includes?(count)
            :one
          else
            :other
          end
        end
      end
    end
  end
end
