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
      rescue Java::ComMicrochipMplabMdbcoreDisasm::InvalidInstructionException
        # The instruction is invalid.
        return :invalid
      end
      MplabInstruction.new instr
    end
  end
end