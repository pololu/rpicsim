require 'rpicsim'
require 'rspec'

require_relative 'rspec/helpers'
require_relative 'rspec/pic_diagnostics'
require_relative 'rspec/be_predicate'

RSpec.configure do |config|
  config.add_setting :sim_shortcuts, default: :all

  # pic_shortcuts is deprecated and just for backwards compatibility
  config.add_setting :pic_shortcuts, default: nil

  config.include RPicSim::RSpec::Helpers
end
