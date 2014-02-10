require_relative 'mplab_memory'
require_relative 'processor'

module RPicSim::Mplab
  # DeviceInfo is a wrapper for the MPLAB xPIC class which gives us information
  # about the target PIC device.
  class Simulator
    # Makes a new DeviceInfo object.
    # @param xpic [com.microchip.mplab.mdbcore.simulator.Simulator]
    def initialize(simulator)
      @simulator = simulator
    end

    def stopwatch_value
      @simulator.GetStopwatchValue
    end

    def fr_memory
      @fr_memory ||= MplabMemory.new data_store.getFileMemory
    end
    
    def program_memory
      @program_memory ||= MplabMemory.new data_store.getProgMemory
    end
    
    def stack_memory
      @stack_memory ||= MplabMemory.new data_store.getStackMemory
    end
    
    def test_memory
      @test_memory ||= MplabMemory.new data_store.getTestMemory
    end
    
    def processor
      @processor ||= Processor.new data_store.getProcessor
    end
    
    def check_peripherals
      check_peripherals_in_data_store
      check_peripheral_set
      check_missing_peripherals
    end

    private

    def data_store
      @simulator.getDataStore
    end
    
    def check_peripherals_in_data_store
      if data_store.getNumPeriphs == 0
        raise "MPLAB X failed to load any peripheral descriptions into the data store."
      end
    end

    def check_peripheral_set
      peripherals = data_store.getProcessor.getPeripheralSet
      if peripherals.getNumPeripherals == 0
        raise "MPLAB X failed to load any peripherals into the PeripheralSet."
      end
    end

    def check_missing_peripherals
      # We have never seen missing peripherals but it seems like a good thing to check.
      peripherals = data_store.getProcessor.getPeripheralSet
      if peripherals.getMissingPeripherals.to_a.size > 0
        raise "This device has missing peripherals: " + peripherals.getMissingReasons().to_a.inspect
      end
    end
    
  end
end