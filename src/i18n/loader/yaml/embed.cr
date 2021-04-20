require "yaml"

path = ARGV.first

raw_translations = [] of String
Dir.glob(path + "/**/*.yml", path + "/**/*.yaml") do |filename|
  raw_translations << File.read(filename)
end

puts <<-LOADER
I18n::Loader::YAML.new(
  I18n::Loader::YAML.normalize_raw_translations(
    #{raw_translations.inspect}
  )
)
LOADER
