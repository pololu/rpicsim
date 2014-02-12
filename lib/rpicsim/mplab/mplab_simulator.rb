require_relative 'mplab_memory'
require_relative 'mplab_processor'

module RPicSim::Mplab
  # DeviceInfo is a wrapper for the MPLAB xPIC class which gives us information
  # about the target PIC device.
  class MplabSimulator
    # Makes a new DeviceInfo object.
    # @param simulator [com.microchip.mplab.mdbcore.simulator.Simulator]
    def initialize(simulator)
      @simulator = simulator
    end

    def stopwatch_value
      @simulator.GetStopwatchValue
    end

    def fr_memory
      @fr_memory ||= MplabMemory.new data_store.getFileMemory
    end
    
    def sfr_memory
      @sfr_memory ||= MplabMemory.new data_store.getSFRMemory
    end

    def nmmr_memory
      @nmmr_memory ||= MplabMemory.new data_store.getNMMRMemory
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
      @processor ||= MplabProcessor.new data_store.getProcessor
    end
    
    def pins
      pin_descs = (0...data_store.getNumPins).collect { |i| data_store.getPinDesc(i) }

      pin_set = data_store.getProcessor.getPinSet

      # The PinSet class has strangely-implemented lazy loading.
      # We call getPin(String name) to force it to load pin data from
      # the SimulatorDataStore.
      pin_descs.each do |pin_desc|
        name = pin_desc.getSignal(0).name  # e.g. "RA0"
        pin_set.getPin name                # Trigger the lazy loading.
      end

      pins = (0...pin_set.getNumPins).collect do |i|
        MplabPin.new pin_set.getPin(i)
      end
    end
    
    def check_peripherals
      check_peripherals_in_data_store
      check_peripheral_set
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
    
    # This is commented out because MPLAB X v2.00 with the PIC18F25K50
    # reports three missing peripherals:
    #  PBADEN_PCFG
    #  config
    #  CONFIG3H.PBADEN
    #
    #def check_missing_peripherals
    #  peripherals = data_store.getProcessor.getPeripheralSet
    #  if peripherals.getMissingPeripherals.to_a.size > 0
    #    raise "This device has missing peripherals: " + peripherals.getMissingReasons().to_a.inspect
    #  end
    #end
    
  end
end