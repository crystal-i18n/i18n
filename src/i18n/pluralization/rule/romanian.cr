module I18n
  module Pluralization
    abstract class Rule
      # Romanian pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Romanian < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1
            :one
          elsif count == 0 || (1..19).to_a.includes?(count % 100)
            :few
          else
            :other
          end
        end
      end
    end
  end
end
