# Locales activation

The current locale - which is used for [translation lookups](/translation_lookups) or [localizations](/localization) - 
can be specified using the `#locale=` method (or `#activate` - both are equivalent):

```crystal
I18n.locale = :fr
I18n.activate(:fr)
```

::: tip
Locale changes like in the above example are always pseudo-global and are scopped to the current fiber.
:::

Unless explicitly set, the default locale (`en` if not configured in `I18n.config.default_locale`) is used instead.

When activating a locale with `#locale=` or `#activate`, all further translations or localizations will be done
using the specified locale. If the specified locale is not part of the available locales (either because it was not part
of the loaded translations or because it was not part of the `I18n.config.available_locales` array), an 
`I18n::Errors::InvalidLocale` exception is raised.

Crystal I18n also provides the ability to execute a block with a specific locale activated. In order to do so, the
`#with_locale` method can be used as follows:

```crystal
I18n.with_locale(:fr) do
  I18n.t("simple.translation") # Will output a text in french
end
```

::: warning
`#with_locale` should be used over `#locale=` or `#activate` in most cases since it will ensure that the previously
activated locale is activated again once the block execution finishes. This is especially relevant in the context of web 
requests processing where a locale matching a given HTTP request has to be activated. In this context, using `#locale=` 
could lead into subsequent requests using the previously activated locale if the later was not reset to its previous 
value after finishing processing the request.
:::
