if ENV['COVERAGE'] == 'Y'
  require 'simplecov'
  SimpleCov.start
end

$LOAD_PATH << 'lib'
require 'rpicsim/rspec'
require_relative 'firmware'

require 'stringio'

RSpec.configure do |config|
  # TODO: remove this stuff and just use 'expect' syntax everywhere
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end
