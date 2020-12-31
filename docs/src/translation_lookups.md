# Translation lookups

Translation lookups can be performed through the use of the `#translate` or `#translate!` methods (or the shorter
equivalents: `#t` or `#t!`). Those methods try to find a matching translation for a specific _key_, which can be 
comprised of multiple namespaces or scopes separated by a dot (`.`). For example `"simple_translation"` is a valid key,
as of `"namespace.simple.translation"`.

When translation lookups are performed for a key that don't match any existing translation, there are two possible
outcomes depending on the method being used:

* `#translate` returns an automatic message indicating that the translation is missing (for example 
  `"missing translation: fr.unknown.translation"`)
* `#translate!` raises an `I18n::Errors::MissingTranslation` exception

## Simple lookups

Simple translation lookups that don't involve interpolations or pluralizations can be performed by specifying the 
intended key to the `#translate` method. For example, the following file defines simple translations:

```yaml
en:
  message: "This is a message"
  simple:
    translation: "This is a simple translation"
```

Given the above translations, the following lookup can be performed using the `#translate` method (or its shorter
equivalent `#t`):

```crystal
I18n.t("simple.translation") # outputs "This is a simple translation"
```

Translation keys can also be expressed as Symbols:

```crystal
I18n.t(:message) # outputs "This is a message"
```

## Interpolations

Variables can be defined in translations and their values can be specified to the `#translate` method as well. As an
example, the following file defines a translation involving variable interpolations:

```yaml
en:
  simple:
    interpolation: "Hello, %{name}!"
```

In order to look up translations involving interpolations, the required variables can be specified either as extra named
arguments to the `#translate` method or as a simple hash or named tuple. The following translation resolutions are all 
equivalent:

```crystal
I18n.t("simple.interpolation", name: "John Doe")         # outputs "Hello, John Doe!"
I18n.t("simple.interpolation", { "name" => "John Doe" }) # outputs "Hello, John Doe!"
I18n.t("simple.interpolation", { name: "John Doe" })     # outputs "Hello, John Doe!"
```

## Pluralization

Pluralization is achieved using a special interpolation variable: `count`. Depending on the value specified for this
variable and the currently activated locale, a predefined pluralization rule is applied in order to identify which 
plural form is considered. These plural forms have to be defined in translation files ; for example the following could
be defined for a pluralized translation in English:

```yaml
en:
  simple:
    pluralization:
      one: "One item"
      other: "%{count} items"
```

::: tip
For many languages like English, only two forms are used: singular and plural. Those correspond respectively to the 
`one` and `other` keys in translation files. However, depending on the language being used other keys could be defined.

Crystal I18n comes with built-in pluralization rules for most of the available locales and supports all the short 
mnemonic tags defined [by the CLDR](http://cldr.unicode.org/index/cldr-spec/plural-rules) for plural categories (`zero`, 
`one`, `two`, `few`, `many` and `other`).

For more details regarding pluralization rules, please consult [Pluralization rules](/pluralization_rules).
:::

In order to resolve translations involving pluralizations, the `count` parameter has to be specified with the intended
value when using the `#translate` method. For example:

```crystal
I18n.t("simple.pluralization", count: 1)  # outputs "One item"
I18n.t("simple.pluralization", count: 42) # outputs "42 items"
```

## Defaults

A default value can be specified in order to be returned if the translation is missing. For example:

```crystal
I18n.t("unknown.pluralization", default: "Unknown")  # outputs "Unknown"
```

## Scopes

Scopes can be specified separately from the translation key if needed. For example, the following translation lookups
are all equivalent:

```crystal
I18n.t("simple.scoped.translation")              # outputs "This is a simple translation"
I18n.t("translation", scope: "simple.scoped")    # outputs "This is a simple translation"
I18n.t("translation", scope: [:simple, :scoped]) # outputs "This is a simple translation"
```
