# Usage: ruby rspec_runner.rb VERSION_REQ [args to rspec]
# Some examples:
#   ruby rspec_runner.rb '~> 2.99.0'  # Uses RSpec 2.99.x
#   ruby rspec_runner.rb '~> 3.0.0'   # Uses RSpec 3.0.x
#
# You need to use '~>' to specify versions because sometimes you will find
# yourself wanting to use gems with slightly different version numbers such as
# rspec-support 3.0.0 with rspec-core 3.0.1.
#
# Loosely specified versions like '~> 2.0' and '~> 3.0' will probably work but
# have some chance of failing because they might end up loading (say) rspec-core
# 2.14.1 and rspec-mocks 2.99.1, which could be incompatible with eachother

version_requirement = Gem::Requirement.new ARGV.shift
major_version = version_requirement.requirements[0][1].segments[0]
gem 'rspec', version_requirement
gem 'rspec-core', version_requirement
gem 'rspec-expectations', version_requirement
gem 'rspec-mocks', version_requirement
if major_version >= 3
  gem 'rspec-support', version_requirement
end
load Gem.bin_path('rspec-core', 'rspec', version_requirement)
