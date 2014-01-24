if ENV["COVERAGE"] == 'Y'
  require "simplecov"
  SimpleCov.start
end

$LOAD_PATH << 'lib'
require 'rpicsim/spec_helper.rb'
require_relative 'firmware'

require 'stringio'