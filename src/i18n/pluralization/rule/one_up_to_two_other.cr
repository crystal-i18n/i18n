module I18n
  module Pluralization
    abstract class Rule
      class OneUpToTwoOther < Rule
        def rule(count : Int) : Symbol
          count && count >= 0 && count < 2 ? :one : :other
        end
      end
    end
  end
end
