require "yaml"

path = ARGV.first

raw_translations = [] of String
Dir.glob(path + "/**/*.json") do |filename|
  raw_translations << File.read(filename)
end

puts <<-LOADER
I18n::Loader::JSON.new(
  I18n::Loader::JSON.normalize_raw_translations(
    #{raw_translations.inspect}
  )
)
LOADER
