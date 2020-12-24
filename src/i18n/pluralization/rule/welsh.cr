module I18n
  module Pluralization
    abstract class Rule
      # Welsh pluralization rule.
      #
      # This rule was initially extracted from [rails-i18n](https://github.com/svenfuchs/rails-i18n).
      class Welsh < Rule
        def apply(count : Float | Int) : Symbol
          case count
          when 0
            :zero
          when 1
            :one
          when 2
            :two
          when 3
            :few
          when 6
            :many
          else
            :other
          end
        end
      end
    end
  end
end
