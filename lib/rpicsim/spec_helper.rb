require 'rpicsim'
require 'rspec'

require_relative 'rspec/helpers'
require_relative 'rspec/pic_diagnostics'
require_relative 'rspec/be_predicate'

RSpec.configure do |config|
  config.add_setting :pic_shortcuts, default: :all
  config.include RPicSim::RSpec::Helpers
end
