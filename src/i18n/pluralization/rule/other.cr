module I18n
  module Pluralization
    abstract class Rule
      # A rule that only returns the "other" pluralization category.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Other < Rule
        def apply(count : Float | Int) : Symbol
          :other
        end
      end
    end
  end
end
