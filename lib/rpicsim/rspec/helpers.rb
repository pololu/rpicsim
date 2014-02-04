require_relative 'persistent_expectations'

module RPicSim
  module RSpec
    # This is the main module of +spec_helper.rb+.
    # It is included in your RSpec examples so that you can call the methods defined here
    # directly in your RSpec examples with no prefix.
    # See {file:RSpecIntegration.md}.
    module Helpers
      include RPicSim::RSpec::PersistentExpectations
      
      # This attribute allows you to type `pic` in your specs instead of `@pic` to
      # get access to the {RPicSim::Pic} instance which represents the simulation.
      # You must call {#start_sim} before using `pic`.
      attr_reader :pic

      # Starts a new simulation with the specified class.
      # @param klass [Class] This should be a subclass of {RPicSim::Pic} or at least act like it.
      # @param args A list of arguments to pass on to the the `new` method of the class.
      #  This should usually be empty unless you have modified your class to take arguments in its
      #  constructor.
      def start_sim(klass, *args)
        @pic = klass.new(*args)
        add_shortcuts
        pic.every_step { check_expectations }
      end

      def add_shortcuts
        case ::RSpec.configuration.pic_shortcuts
        when :all   then extend ::RPicSim::Sim::BasicShortcuts, pic.shortcuts
        when :basic then extend ::RPicSim::Sim::BasicShortcuts
        when :none
        else
          raise "Invalid pic_shortcuts configuration value: #{::RSpec.configuration.pic_shortcuts.inspect}"
        end
      end

    end
  end
end