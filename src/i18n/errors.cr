module I18n
  module Errors
    # Represents an error raised when an attempt to set a non-supported locale is made.
    class InvalidLocale < Exception; end

    # Represents an error raised when a translation cannot be found in a catalog of translations.
    class MissingTranslation < Exception; end
  end
end
