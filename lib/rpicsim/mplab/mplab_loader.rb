require 'java'
require 'pathname'
require 'singleton'

module RPicSim::Mplab
  # This class helps find MPLAB X on the disk, add it to the Java class path
  # so we can use it from JRuby, and figure out what version of MPLAB X we
  # are using.
  #
  # It should not be confused with com.microchip.mplab.mdbcore.loader.Loader,
  # which is used for loading program files.
  class MplabLoader
    include Singleton

    # Adds all the needed MPLAB X jar files to the classpath so we can use the
    # classes.
    def load
      %w{ mdbcore/modules/*.jar
          mplablibs/modules/*.jar
          mplablibs/modules/ext/*.jar
          platform/lib/org-openide-util*.jar
          platform/lib/org-openide-util.jar
          mdbcore/modules/ext/org-openide-filesystems.jar
      }.each do |pattern|
        Dir.glob(jar_dir + pattern).each do |jar_file|
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
          "MPLAB X dir: #{dir}\nMPLAB X jar dir: #{jar_dir}\nClass path:\n" + $CLASSPATH.to_a.join("\n") + "\n\n"
        raise
      end
    end

    # Returns a string like "1.95" representing the version of MPLAB X we are using.
    # NOTE: You should probably NOT be calling this to work around flaws in MPLAB X.
    # Instead, you should add a new entry in flaws.rb and then use
    # RPicSim::Flaws[:FLAWNAME] to see if the flaw exists and choose the appropriate workaround.
    def mplab_version
      # This implementation is not pretty; I would prefer to just find the right function
      # to call.
      @mplab_version ||= begin
        glob_pattern = 'Uninstall_MPLAB_X_IDE_v*'
        paths = Dir.glob(dir + glob_pattern)
        if paths.empty?
          raise "Cannot detect MPLAB X version.  No file matching #{glob_pattern} found in #{dir}."
        end
        matches = paths.map { |p| p.match(/IDE_v([0-9][0-9\.]*[0-9]+)\./) }.compact
        match_data = matches.first
        if !match_data
          raise "Failed to get version number from #{paths.inspect}."
        end
        match_data[1]
      end
    end

    private

    # Returns a Pathname object representing the directory of the MPLAB X we are using.
    # This can either come from the +RPICSIM_MPLABX+ environment variable or it can
    # be auto-detected by looking in the standard places that MPLAB X is installed.
    # @return [Pathname]
    def dir
      @dir ||= begin
        dir = ENV['RPICSIM_MPLABX'] || auto_detect_mplab_dir
        raise "MPLABX directory does not exist: #{dir}" if !File.directory?(dir)
        Pathname(dir)
      end
    end

    def auto_detect_mplab_dir
      # Default installation directories for MPLAB X:
      candidates = [
        'C:/Program Files (x86)/Microchip/MPLABX/',  # 64-bit Windows
        'C:/Program Files/Microchip/MPLABX/',        # 32-bit Windows
        '/opt/microchip/mplabx/',                    # Linux
        '/Applications/microchip/mplabx/',           # Mac OS X
      ]
      dir = candidates.detect { |d| File.directory?(d) }
      raise cannot_find_mplab_error if !dir
      dir
    end

    def cannot_find_mplab_error
      'Cannot find MPLABX.  Install it in the standard location or ' +
      'set the RPICSIM_MPLABX environment variable to its full path.'
    end

    def jar_dir
      @jar_dir ||= if (dir + 'mplab_ide.app').exist?
        dir + 'mplab_ide.app/Contents/Resources/mplab_ide'  # Mac OS X
      else
        dir + 'mplab_ide'
      end
    end
  end
end
