require_relative 'mplab_register'

module RPicSim::Mplab
  class MplabProcessor
    # @param processor [com.microchip.mplab.mdbcore.simulator.Processor]
    def initialize(processor)
      @processor = processor
    end

    def get_pc
      @processor.getPC
    end

    def set_pc(value)
      @processor.setPC(value)
    end

    def get_sfr(name)
      reg = @processor.getSFRSet.getSFR(name)
      raise "Cannot find SFR named '#{name}'." if !reg
      MplabRegister.new(reg)
    end

    def get_nmmr(name)
      reg = @processor.getNMMRSet.getNMMR(name)
      raise "Cannot find NMMR named '#{name}'." if !reg
      MplabRegister.new(reg)
    end
  end
end
