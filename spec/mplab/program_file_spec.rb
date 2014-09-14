require_relative '../spec_helper'

describe 'ProgramFile from MPLAB X' do
  it 'cannot load a file that is not inside a "dist" directory', flaw: true do
    klass = com.microchip.mplab.mdbcore.program.spi.IProgramFileProviderFactory.java_class
    factory = org.openide.util.Lookup.getDefault.lookup(klass)
    program_file = factory.getProvider('spec/firmware/mpasm/BoringLoop.cof', 'PIC10F322')
    exc = com.microchip.mplab.mdbcore.program.exceptions.ProgramFileProcessingException

    if RPicSim::Mplab.version >= '2.15'
      msg = 'Cannot determine a base path for project source files. ' \
            'Some compilers use relative path association and do not store ' \
            'the absolute path with source file entries. As such, the parser ' \
            'expects a COFF debug file to be located in a sub-directory called ' \
            '"dist". This sub-directory should reside directly beneath the ' \
            'location of the project source files. Example: Given the path ' \
            '"C:\x\mplab\makepro\\dist\test1.cof", the parser will extract the ' \
            'base path; "C:\x\mplab\makepro" which will be used to create an ' \
            'absolute path for debug source file entries where the compiler has ' \
            'not specified an absolute path.'
      msg = '"' + msg + ' '
    else
      msg = '"The debug file does not appear to be located in the expected ' \
        'location (/ProjectDir/dist/ConfigName/Debug/???.cof). Has it been moved?"'
    end

    #begin
    #  RPicSim::Mplab.mute_exceptions { program_file.Load }
    #rescue Exception => e
    #  p e.message
    #end

    expect do
      RPicSim::Mplab.mute_exceptions do
        program_file.Load
      end
    end.to raise_error exc, msg
  end
end
