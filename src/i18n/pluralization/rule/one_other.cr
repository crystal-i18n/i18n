module I18n
  module Pluralization
    abstract class Rule
      class OneOther < Rule
        def rule(count : Int) : Symbol
          count == 1 ? :one : :other
        end
      end
    end
  end
end
