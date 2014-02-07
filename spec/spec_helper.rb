if ENV["COVERAGE"] == 'Y'
  require "simplecov"
  SimpleCov.start
end

$LOAD_PATH << 'lib'
require 'rpicsim/rspec'
require_relative 'firmware'

require 'stringio'