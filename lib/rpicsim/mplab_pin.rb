module RPicSim
  class MplabPin
    # Initializes a new Pin object to wrap the given PinPhysical.
    # @param pin_physical [com.microchip.mplab.mdbcore.simulator.PinPhysical]
    def initialize(pin_physical)
      raise ArgumentError, "pin_physical is nil" if pin_physical.nil?
      @pin_physical = pin_physical
    end

    def set_low
      @pin_physical.externalSet PinState::LOW
    end

    def set_high
      @pin_physical.externalSet PinState::HIGH
    end

    def set_analog(value)
      @pin_physical.externalSetAnalogValue value
    end

    # Returns true if the pin is currently configured to be an output,
    # or false if it is configured as an input.  Raises an exception
    # if MPLAB X claims the state is neither, which we think is
    # impossible.
    def output?
      case @pin_physical.getIOState
      when IoState::OUTPUT
        true
      when IoState::INPUT
        false
      else
        raise "invalid IO State: #{io_state}"
      end
    end

    # Returns true if the pin is currently in a "high" state, or false
    # if it is in a "low" state.  Raises an exception if MPLAB X
    # claims the state is neither, which we think is impossible.
    def high?
      case @pin_physical.get
      when PinState::HIGH
        true
      when PinState::LOW
        false
      else
        raise "invalid Pin State: #{pin_state}"
      end
    end

    def names
      @pin_physical.collect(&:name)
    end

    def name
      @pin_physical.pinName
    end    

    private

    PinState = Mdbcore.simulator.Pin::PinState   # HIGH or LOW
    IoState = Mdbcore.simulator.Pin::IOState     # INPUT or OUTPUT
  end
end
