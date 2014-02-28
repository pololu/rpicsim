require 'java'
require 'pathname'

module RPicSim
  module Mplab
    # Returns a Pathname object representing the directory of the MPLAB X we are using.
    # This can either come from the +RPICSIM_MPLABX+ environment variable or it can
    # be auto-detected by looking in the standard places that MPLAB X is installed.
    # @return [Pathname]
    def self.dir
      @dir ||= begin
        dir = ENV['RPICSIM_MPLABX'] or auto_detect_mplab_dir
        raise "MPLABX directory does not exist: #{dir}" if !File.directory?(dir)
        Pathname(dir)
      end
    end
    
    def self.auto_detect_mplab_dir
      candidates = [
        "C:/Program Files (x86)/Microchip/MPLABX/",
        "C:/Program Files/Microchip/MPLABX/",
        "/opt/microchip/mplabx/",
        # TODO: add entries here for MPLAB X folders in Mac OS X
      ]
      dir = candidates.detect { |d| File.directory?(d) }
      raise cannot_find_mplab_error if !dir
      dir
    end

    def cannot_find_mplab_error
      "Cannot find MPLABX.  Install it in the standard location or " +
      "set the RPICSIM_MPLABX environment variable to its full path."
    end

    # Adds all the needed MPLAB X jar files to the classpath so we can use the
    # classes.
    def self.load_dependencies
      %w{ mplab_ide/mdbcore/modules/*.jar
          mplab_ide/mplablibs/modules/*.jar
          mplab_ide/mplablibs/modules/ext/*.jar
          mplab_ide/platform/lib/org-openide-util*.jar
          mplab_ide/platform/lib/org-openide-util.jar
          mplab_ide/mdbcore/modules/ext/org-openide-filesystems.jar
      }.each do |pattern|
        Dir.glob(dir + pattern).each do |jar_file|
          $CLASSPATH << jar_file
        end
      end

      # Do a quick test to make sure we can load some MPLAB X classes.
      # In case MPLAB X was uninstalled and its directory remains, this can provide
      # a useful error message to the user.
      begin
        org.openide.util.Lookup
        com.microchip.mplab.mdbcore.simulator.Simulator
      rescue NameError
        $stderr.puts "Failed to load MPLAB X classes.\n" +
          "MPLAB X dir: #{dir}\nClass path:\n" + $CLASSPATH.to_a.join("\n") + "\n\n"
        raise
      end
    end

    load_dependencies


    # JRuby makes it hard to access packages with capital letters in their names.
    # This is a workaround to let us access those packages.
    module CapitalizedPackages
      include_package "com.microchip.mplab.libs.MPLABDocumentLocator"
    end

    # The com.microchip.mplab.libs.MPLABDocumentLocator.MPLABDocumentLocator class from MPLAB X.
    DocumentLocator = CapitalizedPackages::MPLABDocumentLocator

    # Returns a string like "1.95" representing the version of MPLAB X we are using.
    # NOTE: You should probably NOT be doing this to work around flaws in MPLAB X.
    # Instead, you should add a new entry in flaws.rb and then use
    # RPicSim::Flaws[:FLAWNAME] to see if the flaw exists and choose the appropriate workaround.
    def self.version
      # This implementation is not pretty; I would prefer to just find the right function
      # to call.
      @mplabx_version ||= begin
        paths = Dir.glob(dir + "Uninstall_MPLAB_X_IDE_v*.dat")
        if paths.empty?
          raise "Cannot detect MPLAB X version.  The Uninstall_MPLAB_X_IDE_v*.dat file was not found in #{mplabx_dir}."
        end
        match_data = paths.first.match(/v([0-9][0-9\.]*[0-9]+)\./)
        match_data[1]
      end
    end

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
    class Java::ComMicrochipMplabMdbcoreDisasm::MCDisAsm
      field_accessor :strategy
    end

    # This class helps us suppress the standard output temporarily.
    class NullOutputStream < Java::JavaIo::OutputStream
      def write(b)
      end
    end
    
    Lookup = org.openide.util.Lookup
    Mdbcore = com.microchip.mplab.mdbcore
  end

end

# We want as much awareness as possible; if it becomes a problem we can change this.
com.microchip.mplab.logger.MPLABLogger.mplog.setLevel(java.util.logging.Level::ALL)

require_relative 'mplab/mplab_pin'
require_relative 'mplab/mplab_assembly'
require_relative 'mplab/mplab_program_file'
