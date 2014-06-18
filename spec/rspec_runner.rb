# Usage: ruby rspec_runner.rb VERSION_REQ [args to rspec]
# Some examples:
#   ruby rspec_runner.rb '~> 2.99.0'  # Uses RSpec 2.99.x
#   ruby rspec_runner.rb '~> 3.0.0'   # Uses RSpec 3.0.x

version_requirement = Gem::Requirement.new ARGV.shift
major_version = version_requirement.requirements[0][1].segments[0]
gem 'rspec', version_requirement
gem 'rspec-core', version_requirement.to_s
gem 'rspec-expectations', version_requirement
gem 'rspec-mocks', version_requirement
if major_version >= 3
  gem 'rspec-support', version_requirement
end
load Gem.bin_path('rspec-core', 'rspec', version_requirement)
