module I18n
  # Contains utilities allowing to pluralize translated strings.
  #
  # Custom pluralization rules can be implemented by subclassing the `I18n::Pluralization::Rule` abstract class and by
  # implementing a `#rule` method. Custom pluralization rules can then be registered for specific locale through the use
  # of the `#register_rule` method.
  #
  # ```
  # class CustomRule < I18n::Pluralization::Rule
  #   def rule(count : Int) : Symbol
  #     count == 1 ? :one : :other
  #   end
  # end
  #
  # I18n::Pluralization.register_rule("en-CA", CustomRule)
  # ```
  module Pluralization
    @@rules_registry = {} of ::String => Rule

    # Allows to register a pluralization rule for a specific locale.
    #
    # This method will associate a specific locale to the passed `rule_klass` (subclass of `I18n::Pluralization::Rule`)
    # and ensure that every pluralization performed for this locale are done using this rule.
    def self.register_rule(locale : String | Symbol, rule_klass : Rule.class)
      @@rules_registry[locale.to_s] = rule_klass.new
    end

    # Returns the rule registered for a specific locale, or `nil` if none is registered.
    def self.rule_for(locale : String | Symbol)
      @@rules_registry[locale.to_s]?
    end

    register_rule "en", Rule::OneOther
    register_rule "fr", Rule::OneUpToTwoOther
  end
end
