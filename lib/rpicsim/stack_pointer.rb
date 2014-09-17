module RPicSim
  # Instances of this class represent the call stack pointer in a running
  # simulation.
  # A value of 0 means that the stack is empty, regardless of what device
  # architecture you are simulating.
  # @api public
  class StackPointer
    # Initializes the StackPointer object.
    # This be called when the call stack is empty, because this object uses
    # the initial value of stkptr to deduce how it works.
    # @param stkptr The STKPTR register of the simulation.
    # @api private
    def initialize(stkptr)
      @stkptr = stkptr
      @stkptr_initial_value = @stkptr.value
    end

    # @return [Integer]
    def value
      if @stkptr_initial_value > 0
        raw_value = @stkptr.value
        if raw_value == @stkptr_initial_value
          0
        else
          raw_value + 1
        end
      else
        @stkptr.value
      end
    end

    # @param value [Integer]
    def value=(value)
      @stkptr.value = if @stkptr_initial_value > 0
                        if value == 0
                          @stkptr_initial_value
                        else
                          value - 1
                        end
                      else
                        value
                      end
    end
  end
end
