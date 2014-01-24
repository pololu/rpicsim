module RPicSim
  module Flaws
    # Represents a flaw in RPicSim, usually due to bugs or limitation of the
    # MPLAB X classes we are using.  Stores the name of the flaw and knowledge
    # about what versions of MPLAB X it affects and how.
    class Flaw
      # Creates a new flaw with the specified name.
      # @param name [Symbol] The name of this flaw.
      def initialize(name)
        @versions = {}
      end

      # Returns the effect of this flaw on the specified version of MPLAB X.
      # This might just be true/false to indicate if the flaw is present or it
      # might be a more complicated thing if there is more than one effect the
      # the flaw can have.
      #
      # @param version [String] A version of MPLAB X, e.g. "1.95".
      # @return effect
      def effect(version)
        if @versions.has_key? version
          @versions[version]
        else
          @probable_affect_for_other_versions
        end
      end
      
      # Records the effect this flaw has on a given version of MPLAB X.
      def affects_version(version, effect)
        @versions[version] = effect
      end
      
      # Records the effect that this flaw probably has in other versions of
      # MPLAB X that have not been tested.  This allows us to record our guesses
      # about how the next version of MPLAB X will behave.
      def probably_affects_other_versions(effect)
        @probable_affect_for_other_versions = effect
      end
    end
  
    @flaw_hash = {}
    def self.[](name)
      @flaw_hash[name].effect MPLABX.version
    end
  
    def self.add(name)
      @flaw_hash[name] = flaw = Flaw.new(name)
      yield flaw
    end
  
    add(:fr_memory_attach_useless) do |flaw|
      flaw.affects_version "1.85", false
      flaw.affects_version "1.90", false
      flaw.affects_version "1.95", true
      flaw.affects_version "2.00", true
      flaw.probably_affects_other_versions true
    end
    
    add(:firmware_cannot_write_user_id0) do |flaw|
      flaw.affects_version "1.85", true
      flaw.affects_version "1.90", true
      flaw.affects_version "1.95", false
      flaw.affects_version "2.00", false
      flaw.probably_affects_other_versions false
    end
    
    add(:adc_midrange) do |flaw|
      flaw.affects_version "1.85", :no_middle_values
      flaw.affects_version "1.90", :bad_modulus
      flaw.affects_version "1.95", :bad_modulus
      flaw.affects_version "2.00", :bad_modulus
      flaw.probably_affects_other_versions :bad_modulus
    end
  
  end
end