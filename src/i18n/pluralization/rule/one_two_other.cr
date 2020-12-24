module I18n
  module Pluralization
    abstract class Rule
      # Pluralization rule used for: Cornish, Inari Sami, Inuktitut, Lule Sami, Nama, Northern Sami, Sami Language,
      # Skolt Sami, Southern Sami.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class OneTwoOther < Rule
        def apply(count : Float | Int) : Symbol
          if count == 1
            :one
          elsif count == 2
            :two
          else
            :other
          end
        end
      end
    end
  end
end
