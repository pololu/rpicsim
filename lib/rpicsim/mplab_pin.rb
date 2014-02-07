module RPicSim
  class MplabPin
    PinState = Mdbcore.simulator.Pin::PinState   # HIGH or LOW
    IoState = Mdbcore.simulator.Pin::IOState     # INPUT or OUTPUT

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

    # Returns true if the pin is currently configured to be an output.
    def output?
      io_state = @pin_physical.getIOState
      assert_valid_io_state io_state
      io_state == IoState::OUTPUT
    end

    # Returns true if the pin is currently configured to be an input.
    def input?
      !output?
    end

    def assert_valid_io_state(io_state)
      raise "invalid IO State: #{io_state}" if io_state != IoState::OUTPUT && io_state != IoState::INPUT
    end
  end
end
