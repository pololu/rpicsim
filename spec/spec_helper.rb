if ENV['COVERAGE'] == 'Y'
  require 'simplecov'
  SimpleCov.start
end

require 'stringio'
require 'fileutils'

def rspec_example
  if RSpec.respond_to?(:current_example)
    RSpec.current_example  # RSpec 3.x and 2.99
  else
    example  # RSpec 2.x
  end
end

def mplab_log_files
  Dir.glob('MPLABXLog.xml*')
end

# Remove any MPLAB X log files so we can test to make sure we didn't acidentally
# create any when loading RPicSim or the test firmware.
FileUtils.rm mplab_log_files

$LOAD_PATH << 'lib'
require 'rpicsim/rspec'

require_relative 'firmware'
