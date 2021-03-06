module RPicSim
  module RSpec
    # This simple module is included in {RPicSim::RSpec::Helpers} so it is
    # available in RSpec tests.
    # It provides a way to set expectations on objects that will be checked after
    # every step of the simulation, so you can make sure that the object stays in
    # the state you are expecting it to.
    #
    # Example:
    #     b = []
    #     expecting b => satisfy { |lb| lb.size < 10 }
    #     20.times do
    #       b << 0
    #       check_expectations  # => raises an error once b has 10 elements
    #     end
    #
    # For more information, see {file:PersistentExpectations.md}.
    #
    # @api public
    module PersistentExpectations
      # Returns the current set of persistent expectations.
      # The keys are the objects under test and the values are matchers that
      # we expect to match the object.
      # @return [Hash]
      def expectations
        @expectations ||= {}
      end

      # Checks the expectations; if any object does not match its matcher then
      # it raises an error.
      def check_expectations
        expectations.each do |subject, matcher|
          expect(subject).to matcher if matcher
        end
        nil
      end

      # Adds or removes expectations.
      # The argument should be a hash that associates objects to matchers.
      # A matcher can be any bit of Ruby code that you would be able write in
      # RSpec in place of MATCHER in the code below:
      #
      #     expect(object).to MATCHER
      #
      # For example, you could do:
      #
      #     expecting main_output_pin: be_driving_high
      #
      # To remove an expectation on an object, just provide +nil+ for the matcher.
      #
      # If given a block, applies the new expectations, executes the
      # block, then resets expectations to their former state.
      # Expectation blocks may be nested and freely mixed with other
      # calls to `expecting`.
      def expecting(hash)
        if block_given?
          saved_expectations = expectations.clone
          begin
            expecting(hash)
            yield
          ensure
            @expectations = saved_expectations
          end
        else
          expectations.merge! hash
        end
      end
    end
  end
end
