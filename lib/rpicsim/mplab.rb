require 'java'
require 'pathname'
require_relative 'mplab/mplab_loader'

module RPicSim::Mplab
  @loader = MplabLoader.new
  @loader.load
  
  def self.version
    @loader.mplab_version
  end
  
  # JRuby makes it hard to access packages with capital letters in their names.
  # This is a workaround to let us access those packages.
  capitalized_packages = Module.new
  capitalized_packages.instance_eval do
    include_package "com.microchip.mplab.libs.MPLABDocumentLocator"
  end

  # The com.microchip.mplab.libs.MPLABDocumentLocator.MPLABDocumentLocator class from MPLAB X.
  DocumentLocator = capitalized_packages::MPLABDocumentLocator

  # Mutes the standard output, calls the given block, and then unmutes it.
  def self.mute_stdout
    begin
      orig = java.lang.System.out
      java.lang.System.setOut(java.io.PrintStream.new(NullOutputStream.new))
      yield
    ensure
      java.lang.System.setOut(orig)
    end
  end

  # Mutes a particular type of exception printed by NetBeans,
  # calls the given block, then unmutes it.
  def self.mute_exceptions
    log = java.util.logging.Logger.getLogger('org.openide.util.Exceptions')
    level = log.getLevel
    begin
      log.setLevel(java.util.logging.Level::OFF)
      yield
    ensure
      log.setLevel(level)
    end
  end

  # The MCDisAsm class is the disassembly provided by MPLAB X.
  # We added this part so we could get access to its strategy object, but
  # we are not currently using that feature.
  #class Java::ComMicrochipMplabMdbcoreDisasm::MCDisAsm
  #  field_accessor :strategy
  #end

  # This class helps us suppress the standard output temporarily.
  class NullOutputStream < Java::JavaIo::OutputStream
    def write(b)
    end
  end
  
  Lookup = org.openide.util.Lookup
  Mdbcore = com.microchip.mplab.mdbcore
end

# We want as much awareness as possible; if it becomes a problem we can change this.
com.microchip.mplab.logger.MPLABLogger.mplog.setLevel(java.util.logging.Level::ALL)

# Require the rest of the RPicSim::Mplab Ruby classes now that MPLAB X has been loaded.
require_relative 'mplab/mplab_pin'
require_relative 'mplab/mplab_assembly'
require_relative 'mplab/mplab_program_file'
