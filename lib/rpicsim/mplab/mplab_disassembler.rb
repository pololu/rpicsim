require_relative 'mplab_instruction'

module RPicSim::Mplab
  class MplabDisassembler
    # @param disasm [com.microchip.mplab.mdbcore.disasm.DisAsm]
    def initialize(disasm)
      @disasm = disasm
    end
    
    def disassemble(address)
      # To avoid showing a large, difficult to understand Java trace, we
      # catch the InvalidInstructionException here.
      begin
        instr = @disasm.Disassemble(address, nil, nil)
      rescue Java::ComMicrochipMplabMdbcoreDisasm::InvalidInstructionException => e
        # TODO: actually this should not be an exception because it is expected;
        # so probably you should return nil
        raise "Invalid instruction at address 0x%x." % address
      end
      MplabInstruction.new instr
    end
  end
end