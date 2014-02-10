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
    
    private
    def data_store
      @simulator.getDataStore
    end
  end
end