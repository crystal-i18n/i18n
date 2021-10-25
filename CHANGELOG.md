---
sidebarDepth: 0
---

# Changelog

## 0.2.1 (2021-10-24)

* Add support for Crystal 1.2.1

## 0.2.0 (2021-04-19)

* Add supported for embeddable translations. Embeddable translations provide the ability to embed raw translations 
  inside compiled binaries so that translations files are no longer loaded at runtime

## 0.1.5 (2021-03-21)

* Ensure that catalogs of translations that are initialized from configuration objects leverage normalized translations
  hashes
* Add an "Advanced" section to the documentation

## 0.1.4 (2021-01-24)

* Fix possible missing translations errors when using loaders making use of the same namespaces

## 0.1.3 (2021-01-11)

* Bump Crystal version in shard definition

## 0.1.2 (2021-01-10)

* Fix `I18n#with_locale` and `I18n::Catalog#with_locale` to ensure the value returned by the inner block is properly
  returned if applicable

## 0.1.1 (2021-01-07)

* The pseudo-global catalog of translations (used through the methods provided by `I18n` module) is now properly 
  initialized according to the main configuration object

## 0.1.0 (2021-01-02)

This is the initial release of Crystal I18n!
