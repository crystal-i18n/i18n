# Pluralization rules

## Built-in rules

Crystal I18n has built-in support for most of the existing pluralization rules. All these pluralizations rules are
defined and implemented under the <a href="/ref/I18n/Pluralization/Rule.html" target="_blank"><code>I18n::Pluralization::Rule</code></a>
namespace.

## Custom rules

It is possible to define custom pluralization rules by subclassing the `I18n::Pluralization::Rule` abstract class.
Subclasses must implement an `#apply` method that takes an single `count` argument (float or int) and that returns a
valid [CLDR plural category tag](http://cldr.unicode.org/index/cldr-spec/plural-rules). Some of these tags include 
`:zero`, `:one`, `:two`, `:few`, `:many` and `:other`.

Here is an example pluralization rule that could be written for the English language:

```crystal
class EnglishRule < Rule
  def apply(count : Float | Int) : Symbol
    count == 1 ? :one : :other
  end
end
```

Once implemented, custom pluralization rules have to be "registered" to Crystal I18n by using the <a href="/ref/I18n/Pluralization.html#register_rule(locale:String|Symbol,rule_klass:Rule.class)-class-method" target="_blank"><code>I18n::Pluralization#register_rule</code></a> method. For example the above pluralization rule could be registered to Crystal I18n as follows:

```crystal
I18n::Pluralization.register_rule(:en, EnglishRule)
```

Then, every time pluralized translations need to be generated for the `en` locale, the registered pluralization rule 
will be used automatically by Crystal I18n.
