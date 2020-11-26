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

    register_rule "ak", Rule::OneWithZeroOther
    register_rule "am", Rule::OneWithZeroOther
    register_rule "ar", Rule::Arabic
    register_rule "az", Rule::Other
    register_rule "be", Rule::EastSlavic
    register_rule "bg", Rule::OneOther
    register_rule "bh", Rule::OneWithZeroOther
    register_rule "bm", Rule::Other
    register_rule "bn", Rule::OneOther
    register_rule "bo", Rule::Other
    register_rule "br", Rule::Breton
    register_rule "bs", Rule::EastSlavic
    register_rule "by", Rule::EastSlavic
    register_rule "ca", Rule::OneOther
    register_rule "cs", Rule::WestSlavic
    register_rule "cy", Rule::Welsh
    register_rule "da", Rule::OneOther
    register_rule "de-AT", Rule::OneOther
    register_rule "de-CH", Rule::OneOther
    register_rule "de-DE", Rule::OneOther
    register_rule "de", Rule::OneOther
    register_rule "dz", Rule::Other
    register_rule "el", Rule::OneOther
    register_rule "en-AU", Rule::OneOther
    register_rule "en-CA", Rule::OneOther
    register_rule "en-GB", Rule::OneOther
    register_rule "en-IN", Rule::OneOther
    register_rule "en-NZ", Rule::OneOther
    register_rule "en", Rule::OneOther
    register_rule "eo", Rule::OneOther
    register_rule "es-419", Rule::OneOther
    register_rule "es-AR", Rule::OneOther
    register_rule "es-CL", Rule::OneOther
    register_rule "es-CO", Rule::OneOther
    register_rule "es-CR", Rule::OneOther
    register_rule "es-EC", Rule::OneOther
    register_rule "es-ES", Rule::OneOther
    register_rule "es-MX", Rule::OneOther
    register_rule "es-NI", Rule::OneOther
    register_rule "es-PA", Rule::OneOther
    register_rule "es-PE", Rule::OneOther
    register_rule "es-US", Rule::OneOther
    register_rule "es-VE", Rule::OneOther
    register_rule "es", Rule::OneOther
    register_rule "et", Rule::OneOther
    register_rule "eu", Rule::OneOther
    register_rule "fa", Rule::Other
    register_rule "ff", Rule::OneUpToTwoOther
    register_rule "fi", Rule::OneOther
    register_rule "fr-CA", Rule::OneUpToTwoOther
    register_rule "fr-CH", Rule::OneUpToTwoOther
    register_rule "fr-FR", Rule::OneUpToTwoOther
    register_rule "fr", Rule::OneUpToTwoOther
    register_rule "ga", Rule::Irish
    register_rule "gd", Rule::ScottishGaelic
    register_rule "gl", Rule::OneOther
    register_rule "guw", Rule::OneWithZeroOther
    register_rule "gv", Rule::Manx
    register_rule "he", Rule::OneOther
    register_rule "hi-IN", Rule::OneWithZeroOther
    register_rule "hi", Rule::OneWithZeroOther
    register_rule "hr", Rule::EastSlavic
    register_rule "hsb", Rule::UpperSorbian
    register_rule "hu", Rule::OneOther
    register_rule "id", Rule::Other
    register_rule "ig", Rule::Other
    register_rule "ii", Rule::Other
    register_rule "is", Rule::OneOther
    register_rule "it-CH", Rule::OneOther
    register_rule "it", Rule::OneOther
    register_rule "iu", Rule::OneTwoOther
    register_rule "ja", Rule::Other
    register_rule "jv", Rule::Other
    register_rule "ka", Rule::Other
    register_rule "kab", Rule::OneUpToTwoOther
    register_rule "kde", Rule::Other
    register_rule "kea", Rule::Other
    register_rule "km", Rule::Other
    register_rule "kn", Rule::Other
    register_rule "ko", Rule::Other
    register_rule "ksh", Rule::Colognian
    register_rule "kw", Rule::OneTwoOther
    register_rule "lag", Rule::Langi
    register_rule "ln", Rule::OneWithZeroOther
    register_rule "lo", Rule::Other
    register_rule "lt", Rule::Lithuanian
    register_rule "lv", Rule::Latvian
    register_rule "mg", Rule::OneWithZeroOther
    register_rule "mk", Rule::Macedonian
    register_rule "ml", Rule::OneWithZeroOther
    register_rule "mn", Rule::OneOther
    register_rule "mo", Rule::Romanian
    register_rule "mr-IN", Rule::OneWithZeroOther
    register_rule "ms", Rule::Other
    register_rule "mt", Rule::Maltese
    register_rule "my", Rule::Other
    register_rule "naq", Rule::OneTwoOther
    register_rule "nb", Rule::OneOther
    register_rule "ne", Rule::OneOther
    register_rule "nl", Rule::OneOther
    register_rule "nn", Rule::OneOther
    register_rule "nso", Rule::OneWithZeroOther
    register_rule "oc", Rule::OneOther
    register_rule "or", Rule::OneWithZeroOther
    register_rule "pa", Rule::OneWithZeroOther
    register_rule "pap-AW", Rule::Other
    register_rule "pap-CW", Rule::Other
    register_rule "pl", Rule::Polish
    register_rule "pt", Rule::OneOther
    register_rule "ro", Rule::Romanian
    register_rule "root", Rule::Other
    register_rule "ru", Rule::EastSlavic
    register_rule "sah", Rule::Other
    register_rule "se", Rule::OneTwoOther
    register_rule "ses", Rule::Other
    register_rule "sg", Rule::Other
    register_rule "sh", Rule::EastSlavic
    register_rule "shi", Rule::OneWithZeroOther
    register_rule "sk", Rule::WestSlavic
    register_rule "sl", Rule::Slovenian
    register_rule "sma", Rule::OneTwoOther
    register_rule "smi", Rule::OneTwoOther
    register_rule "smj", Rule::OneTwoOther
    register_rule "smn", Rule::OneTwoOther
    register_rule "sms", Rule::OneTwoOther
    register_rule "sr", Rule::EastSlavic
    register_rule "st", Rule::OneOther
    register_rule "sv-SE", Rule::OneOther
    register_rule "sv", Rule::OneOther
    register_rule "sw", Rule::OneOther
    register_rule "th", Rule::Other
    register_rule "ti", Rule::OneWithZeroOther
    register_rule "to", Rule::Other
    register_rule "tr", Rule::Other
    register_rule "tzm", Rule::CentralMoroccoTamazight
    register_rule "uk", Rule::EastSlavic
    register_rule "ur", Rule::OneOther
    register_rule "vi", Rule::Other
    register_rule "wa", Rule::OneWithZeroOther
    register_rule "wo", Rule::Other
    register_rule "yo", Rule::Other
    register_rule "zh-CN", Rule::Other
    register_rule "zh-HK", Rule::Other
    register_rule "zh-TW", Rule::Other
    register_rule "zh-YUE", Rule::Other
    register_rule "zh", Rule::Other
  end
end
