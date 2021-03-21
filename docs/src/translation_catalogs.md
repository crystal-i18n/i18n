# Translation catalogs

Translation catalogs are used within Crystal I18n in order to perform translation resolutions and localizations. Most of
the time applications won't need to interact with translation catalogs directly and will use methods such as `I18n#t` or
`I18n#l` to perform these operations "globally", but this is something that is possible should the need to handle 
translations separately arises. As a matter of fact, the top-level `I18n` module makes use of a dedicated translation
catalog (instance of <a href="/ref/I18n/Catalog.html" target="_blank"><code>I18n::Catalog</code></a>) to provide common 
features such as locale activation, translation lookups and localizations.

Catalogs of translations hold all the translations for multiple locales and provide the ability to activate specific 
locales in order to define in which locales translated strings should be returned. They can be initialized from common
attributes such as a default locale, an array of available locales and fallbacks. All these arguments are optional: 

```crystal
catalog = I18n::Catalog.new(
  default_locale: "en",
  available_locales: ["en", "fr", "fr-CA"],
  fallbacks: I18n::Locale::Fallbacks.new(
    {"fr-CA-special": ["fr-CA", "fr", "en"]},
    default: ["en"]
  )
)
```

Once initialized it is possible to inject translations into translation catalogs through the use of the `#inject` method
(which accepts a loader instance or a <a href="/ref/I18n/TranslationsHash.html" target="_blank">translation hash</a>):

```crystal
loader = I18n::Loader::YAML.new("config/locales")
catalog.inject(loader)
catalog.inject(I18n::TranslationsHash{
  "en" => I18n::TranslationsHash{
    "simple" => "This is a translation",
  },
})
```

Once translations have been injected into a given catalog, it is possible to perform locale activations, translation
lookups and activations. The methods to use are the same as the ones provided by the `I18n` module:

```crystal
catalog.with_locale(:en) do
  catalog.t("simple")
  catalog.l(Time.local)
end
```
