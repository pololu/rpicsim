require_relative 'mplab_memory'
require_relative 'mplab_processor'

module RPicSim::Mplab
  # This class is a wrapper for thecom.microchip.mplab.mdbcore.simulator.Simulator
  # class, which helps manage running a simulation.
  class MplabSimulator
    # Makes a new MplabSimulator object.
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

    def config_memory
      @config_memory ||= MplabMemory.new data_store.getCFGMemory
    end

    def eeprom_memory
      @eeprom_memory ||= MplabMemory.new data_store.getEEDataMemory
    end

    def processor
      @processor ||= MplabProcessor.new data_store.getProcessor
    end

    def pins
      pin_descs = (0...data_store.getNumPins).map { |i| data_store.getPinDesc(i) }

      pin_set = data_store.getProcessor.getPinSet

      # The PinSet class has strangely-implemented lazy loading.
      # We call getPin(String name) to force it to load pin data from
      # the SimulatorDataStore.
      pin_descs.each do |pin_desc|
        name = pin_desc.getSignal(0).name  # e.g. "RA0"
        pin_set.getPin name                # Trigger the lazy loading.
      end

      (0...pin_set.getNumPins).map do |i|
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
        raise 'MPLAB X failed to load any peripheral descriptions into the data store.'
      end
    end

    def check_peripheral_set
      peripherals = data_store.getProcessor.getPeripheralSet
      if peripherals.getNumPeripherals == 0
        raise 'MPLAB X failed to load any peripherals into the PeripheralSet.'
      end
    end

    # Note: if you are troubleshooting missing peripherals, you could check:
    #  data_store.getProcessor.getPeripheralSet.getMissingPeripherals.to_a
  end
end
