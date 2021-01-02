# Localization

Crystal I18n provides basic localization features for datetimes and numbers. Localization can be achieved through the
use of the `#localize` method (or its shorter version `#l`).

## Localizing dates and datetimes

Localizing dates and datetimes requires a specific structure to be defined in translation files for each of the 
available locales. Here is an example of the expected structure for the `en` locale:

```yaml
en:
  i18n:
    date:
      abbr_day_names: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
      abbr_month_names: [Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec]
      day_names: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
      month_names: [January, February, March, April, May, June,
                    July, August, September, October, November, December]
      formats:
        default: "%Y-%m-%d"
        long: "%B %d, %Y"
        short: "%b %d"
    time:
      am: am
      formats:
        default: "%a, %d %b %Y %H:%M:%S %z"
        long: "%B %d, %Y %H:%M"
        short: "%d %b %H:%M"
      pm: pm
```

The above structure defines basic translations for the relevant directives that can be outputted when localizing dates 
and datetimes. It also defines a few formats under the `i18n.date.formats` and `i18n.time.formats` scopes: among these
formats, only the `default` one is really mandatory since this is the one that is used by default if no other format is 
explicitly provided to the `#localize` method. 

The directives used in the above formats are all defined in the 
[`Time::Format`](https://crystal-lang.org/api/Time/Format.html) struct. As such, custom formats can be created from
any of the directives provided by [`Time::Format`](https://crystal-lang.org/api/Time/Format.html), for example 
`%Y-%m-%d %H:%M:%S %z` is a valid format. Some of these directives (eg. month names) are translated too and thus
additional translation keys have to be defined for those too ; here is a list of the translation keys that need to be
defined for these special time format directives:

| Directive | Translation key | Description
|---|---|---|
| `%a` | `i18n.date.abbr_day_names` | Short day name (Sun, Mon, Tue, ...)
| `%A` | `i18n.date.day_names` | Day name (Sunday, Monday, Tuesday, ...)
| `%b` | `i18n.date.abbr_month_names` | Short month name (Jan, Feb, Mar, ...) 
| `%B` | `i18n.date.month_names` | Month name (January, February, March, ...)
| `%p` | `i18n.time.am`/`i18n.time.pm` | am-pm

Given the above structure and formats definition, it is possibles to localize date and datetimes as follows:

```crystal
I18n.localize(Time.local)             # outputs "Sun, 13 Dec 2020 21:11:08 -0500"
I18n.localize(Time.local, :short)     # outputs "13 Dec 21:11"
I18n.localize(Time.local.date)        # outputs "2020-12-13"
I18n.localize(Time.local.date, :long) # outputs "December 13, 2020"
```

## Localizing numbers

Localizing numbers requires a specific structure to be defined in translation files for each of the available locales. 
Here is an example of the expected structure for the `en` locale:

```yaml
en:
  i18n:
    number:
      formats:
        default:
          delimiter: ","
          separator: "."
          decimal_places: null
          group: 3
          only_significant: false
```

The above structure defines a single `default` format for numbers: similarly to dates or datetimes this `default` format
is mandatory since it'll be used automatically if no explicit format is provided to the `#localize` method, but custom
formats can be defined as well.

Each number format defines how numbers should be formatted for the given locale according to 5 formatting options:

| Option | Default | Description
|---|---|---|
| `delimiter` | `","` | Thousands delimiter between batches of group digits (defaults to)
| `separator` | `"."` | Decimal separator
| `decimal_places` | `null` | Number of visible decimal places (no value means that all significant decimal places are printed)
| `group` | `3` | Number of digits composing the batches of digits used for thousands (defaults to 3)
| `only_significant` | `false` | Whether trailing zeros should be omitted (defaults to false)

::: tip
The above number formatting options are consistent with the arguments that can be used with 
[`Number#format`](https://crystal-lang.org/api/Number.html#format(separator='.',delimiter=',',decimal_places:Int?=nil,*,group:Int=3,only_significant:Bool=false):String-instance-method)
:::

Given the above structure and formats definition, it is possibles to localize numbers as follows:

```crystal
I18n.localize(123_456)              # outputs "123,456"
I18n.localize(123_456.789)          # outputs "123,456.789"
I18n.localize(123_456.789, :custom) # outputs "123,456.79"
```
