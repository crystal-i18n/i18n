# Translation loaders

Translation loaders are used to load translation files in order to "inject" the resulting data into 
[catalogs of translations](/translation_catalogs). Translations loaders are configured through the use of the
<a href="/ref/I18n/Config.html#loaders:Array(I18n::Loader::Base)-instance-method" target="_blank"><code>I18n::Config#loaders</code></a>
method:

```crystal
I18n.config.loaders << I18n::Loader::YAML.new("config/locales")
```

## Built-in translation loaders

Crystal I18n has built-in support for two loader types:

* <a href="/ref/I18n/Loader/YAML.html" target="_blank"><code>I18n::Loader::YAML</code></a> - allows to load YAML 
  translations files
* <a href="/ref/I18n/Loader/JSON.html" target="_blank"><code>I18n::Loader::JSON</code></a> - allows to load JSON
  translations files

Each of the above loader implementation supports translations files organized accross multiple files (eg. multiple
YAML files organized in sub-directories for a specific locale). The above loaders can be initialized from an absolute or 
relative directory path (where translations files will be looked up).

Most frequently, built-in translations loaders will be used to define translations that are loaded at runtime. This is
achieved by initializing the loader objects as follows:

```crystal
I18n.config.loaders << I18n::Loader::YAML.new("config/locales")
```

In order to ensure that raw translations are embedded inside the compiled binary, it is possible to use the 
`#embed` method:

```crystal
I18n.config.loaders << I18n::Loader::YAML.embed("config/locales")
```

## Custom translation loaders

It is possible to write new translation files in order to load translations from other data sources. For example it 
could be possible to write translation loaders to load translations from a database, XML files, etc.

To do so, it is necessary to subclass the `I18n::Loader::Base` abstract class and to provide a `#load` method that 
returns a valid <a href="/ref/I18n/TranslationsHash.html" target="_blank">translation hash</a>:

```crystal
class MyLoader < I18n::Loader::Base
  def load : I18n::TranslationsHash
    translations = I18n::TranslationsHash.new
    # fetch translations
    translations
  end
end
```

_How_ translations loaders are initialized is something that is up to each translation loader implementation.
