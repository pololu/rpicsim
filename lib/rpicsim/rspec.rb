require 'rpicsim'
require 'rspec'

require_relative 'rspec/helpers'
require_relative 'rspec/sim_diagnostics'
require_relative 'rspec/be_predicate'

RSpec.configure do |config|
  config.add_setting :sim_shortcuts, default: :all
  config.include RPicSim::RSpec::Helpers
end
