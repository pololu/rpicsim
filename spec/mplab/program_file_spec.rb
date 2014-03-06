require_relative '../spec_helper'

describe 'ProgramFile from MPLAB X' do
  it 'cannot load a file that is not inside a "dist" directory', flaw: true do
    klass = com.microchip.mplab.mdbcore.program.spi.IProgramFileProviderFactory.java_class
    factory = org.openide.util.Lookup.getDefault.lookup(klass)
    program_file = factory.getProvider('spec/firmware/BoringLoop.cof', 'PIC10F322')
    exc = com.microchip.mplab.mdbcore.program.exceptions.ProgramFileProcessingException

    msg = '"The debug file does not appear to be located in the expected ' \
      'location (/ProjectDir/dist/ConfigName/Debug/???.cof). Has it been moved?"'

    expect do
      RPicSim::Mplab.mute_exceptions do
        program_file.Load
      end
    end.to raise_error exc, msg
  end
end
