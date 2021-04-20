# Configuration

Crystal I18n can be configured through the use of the `I18n#config` object (instance of 
<a href="/ref/I18n/Config.html" target="_blank"><code>I18n::Config</code></a>). This object allows to configure various
aspects of the behaviour of Crystal I18n, such as: how translation files are loaded, the default locale, etc.

## `loaders`

**Default value:** `[] of I18n::Loader::Base`

The <a href="/ref/I18n/Config.html#loaders:Array(I18n::Loader::Base)-instance-method" target="_blank"><code>I18n::Config#loaders</code></a>
method gives access to the
list of configured translations loaders and allows to easily append new ones. For example:

```crystal
I18n.config.loaders << I18n::Loader::YAML.new("config/locales")
```

Each object in the `loaders` array must be an instance of a subclass of `I18n::Loader::Base` (abstract class which 
defines how translations should be "loaded" in order to be injected into catalogs of translations). Crystal I18n has 
built-in support for two loader types:

* <a href="/ref/I18n/Loader/YAML.html" target="_blank"><code>I18n::Loader::YAML</code></a> - allows to load YAML 
  translations files
* <a href="/ref/I18n/Loader/JSON.html" target="_blank"><code>I18n::Loader::JSON</code></a> - allows to load JSON
  translations files

Each of the above loader implementation supports translations organized accross multiple files (eg. multiple YAML files 
organized in sub-directories for a specific locale). The above loaders are initialized from an absolute or relative 
directory path (where translations files will be looked up).

::: tip
The built-in translations loaders (YAML or JSON) provide the ability to embed raw translations in compiled binaries (so 
that translations files are not loaded at runtime). This is possible through the use of the `#embed` macro:

```crystal
I18n.config.loaders << I18n::Loader::YAML.embed("config/locales")
```
:::

It's also possible to fully define the existing loaders at once through the use of the <a href="/ref/I18n/Config.html#loaders=(loaders)-instance-method" target="_blank"><code>I18n::Config#loaders=</code></a>
method:

```crystal
I18n.config.loaders = [I18n::Loader::YAML.new("config/locales")] of I18n::Loader::Base
```

::: warning
The order of `#loaders` is important, especially if the same translations are defined in multiple places accross files
that are targetted by multiple loaders. For example in a situation where a `simple.translation` translation is defined 
by a file that is loaded by a loader **L1** while the same translation is also defined by a file that is loaded by a 
loader **L2**, the second translation will be used if **L1** comes first in the `#loaders` array.
:::

## `default_locale`

**Default value:** `"en"`

The <a href="/ref/I18n/Config.html#default_locale=(locale:String%7CSymbol)-instance-method" target="_blank"><code>I18n::Config#default_locale=</code></a>
method allows to set the default locale used by Crystal I18n. The default locale is set to `"en"` (English) unless
explicitly set:

```crystal
I18n.config.default_locale = :fr
```

## `available_locales`

**Default value:** `nil`

The <a href="/ref/I18n/Config.html#available_locales=(available_locales:Array(String%7CSymbol)?)-instance-method" target="_blank"><code>I18n::Config#available_locales=</code></a>
method allows to define the locales that can be activated in order to perform translation lookups and localizations. 
Unless explicitly specified, this list corresponds to the locales that are automatically discovered by translations 
loaders configured via the `#loaders` method.

```crystal
I18n.config.available_locales = [:en, :fr]
```

## `fallbacks`

**Default value:** `nil`

The <a href="/ref/I18n/Config.html#fallbacks=(fallbacks:Array(String%7CSymbol)%7CHash(String%7CSymbol,Array(String%7CSymbol)%7CString%7CSymbol)%7CLocale::Fallbacks%7CNamedTuple%7CNil)-instance-method" target="_blank"><code>I18n::Config#fallbacks=</code></a>
method allows to set the locale fallbacks. Setting locale fallbacks will force Crystal I18n to try to lookup 
translations in other (configured) locales if the current locale the translation is requested into is missing.

For example, the specified fallbacks can be a hash or a named tuple defining the chains of fallbacks to use for specific 
locales:

```crystal
I18n.config.fallbacks = {"en-CA" => ["en-US", "en"], "fr-CA" => "fr"}
```

It can also be a simple array of fallbacks. In that case, this chain of fallbacked locales will be used as a default for 
all the available locales when translations are missing:

```crystal
I18n.config.fallbacks = ["en-US", "en"]
```

It's also possible to specficy both default fallbacks and a mapping of fallbacks by initializing an 
`I18n::Locale::Fallbacks` object as follows:

```crystal
I18n.config.fallbacks = I18n::Locale::Fallbacks.new(
  {"fr-CA-special": ["fr-CA", "fr", "en"]},
  default: ["en"]
)
```

Finally, using `nil` in the context of this method will reset the configured fallbacks (and remove any previously 
configured fallbacks).

It's also important to always ensure that fallback locales are available locales: they should all be present in the 
`#available_locales` array.
