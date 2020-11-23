module I18n
  module Loader
    abstract class Base
      abstract def load : TranslationsHash
    end
  end
end
