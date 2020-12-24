require "./spec_helper"

describe I18n::Pluralization do
  describe "::register_rule" do
    it "allows to register a rule for a specific locale" do
      I18n::Pluralization.register_rule("dummy-locale-1", I18n::Pluralization::Rule::OneWithZeroOther)
      I18n::Pluralization.register_rule(:"dummy-locale-2", I18n::Pluralization::Rule::OneOther)
      I18n::Pluralization.rule_for("dummy-locale-1").should be_a I18n::Pluralization::Rule::OneWithZeroOther
      I18n::Pluralization.rule_for("dummy-locale-2").should be_a I18n::Pluralization::Rule::OneOther
    end
  end

  describe "::rule_for" do
    it "returns the rule for a given locale" do
      I18n::Pluralization.rule_for("en").should be_a I18n::Pluralization::Rule::OneOther
      I18n::Pluralization.rule_for(:fr).should be_a I18n::Pluralization::Rule::OneUpToTwoOther
    end

    it "returns nil if no rule is registered for the passed locale" do
      I18n::Pluralization.rule_for(:unknown).should be_nil
    end
  end
end
