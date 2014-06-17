# We override some parts of RSpec to provide better error messages.
# This is only needed for RSpec 2.x, since th messages improved in RSpec 3.x
# Instead of 'expected driving_high? to return true, got false' RSpec will actually
# tell us what object it called driving_high on.
class RSpec::Matchers::BuiltIn::BePredicate
  if instance_methods.include?(:failure_message_for_should)
    # RSpec 2.x

    def failure_message_for_should
      "expected `#{actual.inspect}.#{predicate}#{args_to_s}` to return true, got #{@result.inspect}"
    end

    def failure_message_for_should_not
      "expected `#{actual.inspect}.#{predicate}#{args_to_s}` to return false, got #{@result.inspect}"
    end
  end
end
