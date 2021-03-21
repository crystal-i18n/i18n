module I18n
  alias TranslationsHashValues = Bool | Int32 | Nil | String | Array(String) | Hash(String, TranslationsHashValues)

  # A translation hash corresponds to a hash that must be returned by `I18n::Loader::Base` subclasses when translations
  # are loaded from a specific source.
  alias TranslationsHash = Hash(String, TranslationsHashValues)
end
