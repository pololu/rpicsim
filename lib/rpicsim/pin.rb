# @api public
module RPicSim
  # This class represents an external pin of the simulated device.
  # It provides methods for reading the pin's output value and setting
  # its input value.
  #
  # @api public
  class Pin
    # Initializes a new Pin object to wrap the given MplabPin.
    # @param mplab_pin [Mplab::MplabPin]
    # @api private
    def initialize(mplab_pin)
      raise ArgumentError, 'mplab_pin is nil' if mplab_pin.nil?
      @mplab_pin = mplab_pin
    end

    # Sets the external stimulus input voltage applied to the pin.
    # The boolean values true and false correspond to high and low, respectively.
    # Numeric values (e.g. Float or Integer) correspond to analog voltages.
    def set(state)
      case state
      when false   then @mplab_pin.set_low
      when true    then @mplab_pin.set_high
      when Numeric then @mplab_pin.set_analog(state)
      else raise ArgumentError, "Invalid pin state: #{state.inspect}."
      end
    end

    # Returns true if the pin is currently configured to be an output.
    def output?
      @mplab_pin.output?
    end

    # Returns true if the pin is currently configured to be an input.
    def input?
      !@mplab_pin.output?
    end

    # Returns true if the pin is currently configured to be an output and
    # it is driving high.
    def driving_high?
      output? && @mplab_pin.high?
    end

    # Returns true if the pin is currently configured to be an output and
    # it is driving low.
    def driving_low?
      output? && !@mplab_pin.high?
    end

    # Returns an array of all the pin's names from the datasheet, like
    # "RA4" or "TX".
    # @return [String]
    def names
      @mplab_pin.names
    end

    # @return [String]
    def to_s
      @mplab_pin.name
    end

    # @return [String]
    def inspect
      '#<%s %s>' % [self.class, to_s]
    end
  end
end
