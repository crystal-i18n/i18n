module I18n
  module Loader
    # Translations loader base class.
    abstract class Base
      # Loads the translations targetted by the current loader.
      abstract def load : TranslationsHash

      # Allows to embed raw translations inside compiled binaries.
      #
      # This macro is not implemented by default and is optional. Depending on the considered loader, and how / where
      # translations are stored, this feature could implemented or not.
      macro embed(path)
        {% raise "Not implemented" %}
      end
    end
  end
end
