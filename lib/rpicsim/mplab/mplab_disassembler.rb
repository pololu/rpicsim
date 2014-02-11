require_relative 'mplab_instruction'

module RPicSim::Mplab
  class MplabDisassembler
    # @param disasm [com.microchip.mplab.mdbcore.disasm.DisAsm]
    def initialize(disasm)
      @disasm = disasm
    end
    
    def disassemble(address)
      MplabInstruction.new @disasm.Disassemble(address, nil, nil)
    end
  end
end