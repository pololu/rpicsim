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
      io_state = @pin_physical.getIOState
      case io_state
      when IoState::OUTPUT then true
      when IoState::INPUT  then false
      else
        raise "Invalid IO state: #{io_state}"
      end
    end

    # Returns true if the pin is currently in a "high" state, or false
    # if it is in a "low" state.  Raises an exception if MPLAB X
    # claims the state is neither, which we think is impossible.
    def high?
      pin_state = @pin_physical.get
      case pin_state
      when PinState::HIGH then true
      when PinState::LOW  then false
      else
        raise "Invalid pin state: #{pin_state}"
      end
    end

    def names
      @pin_physical.collect(&:name)
    end

    def name
      @pin_physical.pinName
    end    

    PinState = Mdbcore.simulator.Pin::PinState   # HIGH or LOW
    IoState = Mdbcore.simulator.Pin::IOState     # INPUT or OUTPUT
  end
end
