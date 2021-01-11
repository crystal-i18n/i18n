---
sidebarDepth: 0
---

# Changelog

## 0.1.2 (2021-01-10)

* Fix `I18n#with_locale` and `I18n::Catalog#with_locale` to ensure the value returned by the inner block is properly
  returned if applicable

## 0.1.1 (2021-01-07)

* The pseudo-global catalog of translations (used through the methods provided by `I18n` module) is now properly 
  initialized according to the main configuration object

## 0.1.0 (2021-01-02)

This is the initial release of Crystal I18n!
