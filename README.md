# Crystal I18n

![logo](https://raw.githubusercontent.com/crystal-i18n/i18n/main/docs/src/.vuepress/public/assets/img/hero.svg)

[![Version](https://img.shields.io/github/v/tag/crystal-i18n/i18n)](https://github.com/crystal-i18n/i18n/tags)
[![License](https://img.shields.io/github/license/crystal-i18n/i18n)](https://github.com/crystal-i18n/i18n/blob/main/LICENSE)
[![CI](https://github.com/crystal-i18n/i18n/workflows/CI/badge.svg)](https://github.com/crystal-i18n/i18n/actions)

---

**Crystal I18n** is an internationalization library for the Crystal programming language. It provides a unified interface 
allowing to leverage translations and localized contents in a Crystal project.

Features:

* Translation lookups
* Localization
* Interpolation
* Pluralization rules
* Locale fallbacks
* Flexible configuration

## Documentation

Online browsable documentation is available at https://crystal-i18n.github.io/.

## Installation

Simply add the following entry to your project's `shard.yml`:

```yaml
dependencies:
  i18n:
    github: crystal-i18n/i18n
```

And run `shards install` afterwards.

## Usage

Assuming that a `config/locales` relative folder exists in your project, with the following `en.yml` file in it:

```yaml
en:
  simple:
    translation: "This is a simple translation"
    interpolation: "Hello, %{name}!"
    pluralization:
      one: "One item"
      other: "%{count} items"
```

The following setup could be performed in order to initialize `I18n` properly:

```crystal
require "i18n"

I18n.config.loaders << I18n::Loader::YAML.new("config/locales")
I18n.config.default_locale = :en
I18n.init
```

Here a translation loader is configured to load the previous translation file while also configuring the default locale 
(`en`) and initializing the `I18n` module.

Translations lookups can now be performed using the `#translate` method (or the shorter version `#t`) as follows:

```crystal
I18n.t("simple.translation")                     # outputs "This is a simple translation"
I18n.t("simple.interpolation", name: "John Doe") # outputs "Hello, John Doe!"
I18n.t("simple.pluralization", count: 42)        # outputs "42 items"
```

Please head over to the [documentation](https://crystal-i18n.github.io/) for a more complete overview of the `I18n` 
module capabilities (including the configuration options, localization features, etc).

## Authors

Morgan Aubert ([@ellmetha](https://github.com/ellmetha)) and 
[contributors](https://github.com/crystal-i18n/i18n/contributors).

## Credits

Crystal I18n initially draws its inspiration from [Ruby I18n](https://github.com/ruby-i18n/i18n) and 
[rails-i18n](https://github.com/svenfuchs/rails-i18n). Originally, pluralization and localization rules all come from
[rails-i18n](https://github.com/svenfuchs/rails-i18n) as well.

## License

MIT. See ``LICENSE`` for more details.
