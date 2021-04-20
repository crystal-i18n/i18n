require "./spec_helper"

describe I18n::Loader::JSON do
  describe "::normalize_raw_translations" do
    it "returns a translations hash corresponding to an array of raw translations" do
      I18n::Loader::JSON.normalize_raw_translations(
        [
          File.read("spec/i18n/loader/locales/json/en.json"),
          File.read("spec/i18n/loader/locales/json/fr.json"),
        ]
      ).should eq I18n::TranslationsHash{
        "en" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "This is a simple translation",
          },
        },
        "fr" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "C'est une traduction simple",
          },
        },
      }
    end
  end

  describe "::embed" do
    it "returns a JSON loader with preloaded translations in it" do
      loader = I18n::Loader::JSON.embed("spec/i18n/loader/locales/json")

      expected_translations = I18n::TranslationsHash{
        "en" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "This is a simple translation",
          },
        },
        "fr" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "C'est une traduction simple",
          },
        },
      }

      loader.should be_a I18n::Loader::JSON
      loader.path.should be_nil
      loader.preloaded_translations.should eq expected_translations
      loader.load.should eq expected_translations
    end
  end

  describe "#load" do
    it "returns the expected translations hash when the loader is initialized from a path" do
      loader = I18n::Loader::JSON.new("spec/i18n/loader/locales/json")
      loader.load.should eq I18n::TranslationsHash{
        "en" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "This is a simple translation",
          },
        },
        "fr" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "C'est une traduction simple",
          },
        },
      }
    end

    it "returns the expected translations hash when the loader is initialized from preloaded translations" do
      loader = I18n::Loader::JSON.new(
        I18n::Loader::JSON.normalize_raw_translations(
          [
            File.read("spec/i18n/loader/locales/json/en.json"),
            File.read("spec/i18n/loader/locales/json/fr.json"),
          ]
        )
      )
      loader.load.should eq I18n::TranslationsHash{
        "en" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "This is a simple translation",
          },
        },
        "fr" => I18n::TranslationsHash{
          "simple" => I18n::TranslationsHash{
            "translation" => "C'est une traduction simple",
          },
        },
      }
    end
  end
end
