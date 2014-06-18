# Usage: ruby rspec_runner.rb VERSION [args to rspec]
version_string = ARGV.shift
version = Gem::Version.new version_string
version_specifier = "~> #{version_string}"
gem 'rspec', version_specifier
gem 'rspec-core', version_specifier
gem 'rspec-expectations', version_specifier
gem 'rspec-mocks', version_specifier
if version.segments.first >= 3
  gem 'rspec-support', version_specifier
end
load Gem.bin_path('rspec-core', 'rspec') #, version_specifier)
