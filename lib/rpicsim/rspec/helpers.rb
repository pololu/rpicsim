require_relative 'persistent_expectations'

module RPicSim
  module RSpec
    # This is the main module of +spec_helper.rb+.
    # It provides the {#start_sim} method and includes {PersistentExpectations}.
    # See {file:RSpecIntegration.md}.
    module Helpers
      include RPicSim::RSpec::PersistentExpectations
      
      # This attribute allows you to type `sim` in your specs instead of `@sim` to
      # get access to the {RPicSim::Sim} instance which represents the simulation.
      # You must call {#start_sim} before using `sim`.
      attr_reader :sim

      # @deprecated Use {#sim} instead.
      alias :pic :sim

      # Starts a new simulation with the specified class, makes it
      # accessible via the attribute {#sim}, and adds convenience
      # methods using {#add_shortcuts}.
      # @param klass [Class] This should be a subclass of {RPicSim::Sim} or at least act like it.
      # @param args A list of arguments to pass on to the the `new` method of the class.
      #  This should usually be empty unless you have modified your class to take arguments in its
      #  constructor.
      def start_sim(klass, *args)
        @sim = klass.new(*args)
        add_shortcuts
        sim.every_step { check_expectations }
      end

      def add_shortcuts
        configuration_value = ::RSpec.configuration.pic_shortcuts || ::RSpec.configuration.sim_shortcuts
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
