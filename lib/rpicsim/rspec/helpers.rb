require_relative 'persistent_expectations'

module RPicSim
  module RSpec
    # This module gets included into your RSpec examples if you use the
    # following line in your spec_helper.rb:
    #
    #     require 'rpicsim/rspec'
    #
    # It provides the {#start_sim} method and includes all the methods from
    # {PersistentExpectations}.
    #
    # For more information, see {file:RSpecIntegration.md}.
    #
    # @api public
    module Helpers
      include PersistentExpectations

      # This attribute allows you to type +sim+ in your specs instead of +@sim+ to
      # get access to the {RPicSim::Sim} instance which represents the simulation.
      # You must call {#start_sim} before using +sim+.
      attr_reader :sim

      # Starts a new simulation with the specified class, makes it
      # accessible via the attribute {#sim}, and adds convenient
      # shortcut methods that can be used in the RSpec example.
      # @param klass [Class] This should be a subclass of {RPicSim::Sim} or at least act like it.
      # @param args A list of arguments to pass on to the the +new+ method of the class.
      #  This should usually be empty unless you have modified your class to take arguments in its
      #  constructor.
      def start_sim(klass, *args)
        @sim = klass.new(*args)
        add_shortcuts
        sim.every_step { check_expectations }
      end

      # @api private
      def add_shortcuts
        configuration_value = ::RSpec.configuration.sim_shortcuts
        case configuration_value
        when :all   then extend ::RPicSim::Sim::BasicShortcuts, sim.shortcuts
        when :basic then extend ::RPicSim::Sim::BasicShortcuts
        when :none
        else
          raise "Invalid sim_shortcuts configuration value: #{configuration_value.inspect}"
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.add_setting :sim_shortcuts, default: :all
  config.include RPicSim::RSpec::Helpers
end
