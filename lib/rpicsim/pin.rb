module RPicSim
  # This class represents an external pin of the simulated device.
  # It provides methods for reading the pin's output value and setting
  # its input value.
  class Pin
    PinState = Mdbcore.simulator.Pin::PinState   # HIGH or LOW
    IoState = Mdbcore.simulator.Pin::IOState     # INPUT or OUTPUT
    
    # Initializes a new Pin object to wrap the given PinPhysical.
    # @param pin_physical [com.microchip.mplab.mdbcore.simulator.PinPhysical]
    def initialize(pin_physical)
      raise ArgumentError, "pin_physical is nil" if pin_physical.nil?
      @pin_physical = pin_physical
    end

    # Sets the external stimulus input voltage applied to the pin.
    # The boolean values true and false correspond to high and low, respectively.
    # Numeric values (e.g. Float or Integer) correspond to analog voltages.
    def set(state)
      case state
      when false   then @pin_physical.externalSet PinState::LOW
      when true    then @pin_physical.externalSet PinState::HIGH
      when Numeric then @pin_physical.externalSetAnalogValue state
      else raise ArgumentError, "Invalid pin state: #{state.inspect}."
      end
    end

    # Returns true if the pin is currently configured to be an output.
    def output?
      @pin_physical.getIOState == IoState::OUTPUT
    end
    
    # Returns true if the pin is currently configured to be an input.
    def input?
      @pin_physical.getIOState == IoState::INPUT
    end
    
    # Returns true if the pin is currently configured to be an output and
    # it is driving high.
    def driving_high?
      output? && @pin_physical.get == PinState::HIGH
    end

    # Returns true if the pin is currently configured to be an output and
    # it is driving low.
    def driving_low?
      output? && @pin_physical.get == PinState::LOW
    end

    # Returns true if the given name is one of the names of the pin.
    # @param name [String] A name from datasheet, like "RA4" or "TX".
    def is_named?(name)
      @pin_physical.isNamed(name)
    end

    # Returns an array of all the pin's names.
    def names
      @pin_physical.collect(&:name)
    end
    
    def to_s
      @pin_physical.pinName
    end    

    def inspect
      "#<%s %s>" % [self.class, to_s]
    end
  end
end