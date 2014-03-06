require_relative 'mplab_device_info'
require_relative 'mplab_simulator'
require_relative 'mplab_disassembler'

module RPicSim::Mplab
  # This class wraps objects belonging to the abstract Java class
  # com.microchip.mplab.mdbcore.assemblies.Assembly,
  # which represent a collection of objects being used together.
  class MplabAssembly
    attr_reader :device

    def initialize(device)
      @device = device
      assembly_factory = Lookup.default.lookup(Mdbcore.assemblies.AssemblyFactory.java_class)
      RPicSim::Mplab.mute_stdout do
        @assembly = assembly_factory.create(device)
      end
    end

    # Connect the assembly to a simulator and debugger.
    def start_simulator_and_debugger(filename)
      # In MPLAB X v1.70, this line had to be before the call to SetTool, or else when we run
      # debugger.Connect we will get two lines of: [Fatal Error] :1:1: Premature end of file.
      simulator

      sim_meta = Mdbcore.platformtool.PlatformToolMetaManager.getTool('Simulator')
      @assembly.SetTool(sim_meta.configuration_object_id, sim_meta.class_name, sim_meta.flavor, '')
      if !sim_meta.getToolSupportForDevice(device).all? &:isSupported
        raise "Microchip's simulator does not support " + device + '.'
      end
      @assembly.SetHeader('')  # The Microchip documentation doesn't say what this is.
      debugger.Connect(Mdbcore.debugger.Debugger::CONNECTION_TYPE::DEBUGGER)

      # Load our firmware into the simulator.
      load_file(filename)
      debugger.Program(Mdbcore.debugger.Debugger::PROGRAM_OPERATION::AUTO_SELECT)

      check_for_errors

      nil
    end

    def load_file(filename)
      loader.Load(filename)
    end

    def debugger_step
      debugger.StepInstr
    end

    # Gets a com.microchip.mplab.mdbcore.simulator.Simulator object.
    def simulator
      @simulator ||= MplabSimulator.new lookup Mdbcore.simulator.Simulator.java_class
    end

    # Gets a com.microchip.mplab.mdbcore.disasm.Disasm object which we can
    # use to disassemble the program binary.
    def disassembler
      @disassembler ||= MplabDisassembler.new lookup Mdbcore.disasm.DisAsm.java_class
    end

    def device_info
      @device_info ||= MplabDeviceInfo.new(@assembly.GetDevice)
    end

    private
    # Gets a com.microchip.mplab.mdbcore.debugger.Debugger object.
    def debugger
      lookup Mdbcore.debugger.Debugger.java_class
    end

    def loader
      lookup Mdbcore.loader.Loader.java_class
    end

    def lookup(klass)
      @assembly.getLookup.lookup klass
    end

    def check_for_errors
      warn_about_5C
      warn_about_path_retrieval
      @simulator.check_peripherals
    end

    def warn_about_5C
      # Detect a problem that once caused peripherals to load incorrectly.
      # More info: http://stackoverflow.com/q/15794170/28128
      f = DocumentLocator.java_class.resource('MPLABDocumentLocator.class').getFile()
      if f.include?('%5C')
        $stderr.puts 'warning: A %5C character was detected in the ' \
          'MPLABDocumentLoator.class file location.  ' \
          'This might cause errors in the Microchip code.'
      end
    end

    def warn_about_path_retrieval
      # See spec/mplab_x/path_retrieval_spec.rb for more info.
      retrieval = com.microchip.mplab.open.util.pathretrieval.PathRetrieval
      path = retrieval.getPath(DocumentLocator.java_class)
      if !java.io.File.new(path).exists()
        $stderr.puts "warning: MPLAB X will be looking for files at a bad path: #{path}"
      end
    end

  end
end
