# @api public
module RPicSim
  # This module stores knowledge about flaw in RPicSim, usually due to bugs or
  # limitation of the MPLAB X classes we are using.  See {file:KnownIssues.md}
  # for more details.
  #
  # @api public
  module Flaws
    # Represents a flaw in RPicSim, usually dues to bugs in the MPLAB X classes
    # we are using.  Stores the name of the flaw and knowledge about what
    # versions of MPLAB X it affects and how.
    class Flaw
      # Creates a new flaw with the specified name.
      # @param name [Symbol] The name of this flaw.
      # @api private
      def initialize(name)
        @versions = {}
      end

      # Returns the effect of this flaw on the specified version of MPLAB X.
      # This might just be true/false to indicate if the flaw is present or it
      # might be a more complicated thing if there is more than one effect the
      # the flaw can have.
      #
      # @param version [String] A version of MPLAB X, e.g. +'1.95'+.
      # @return effect
      def effect(version)
        if @versions.key? version
          @versions[version]
        else
          @probable_affect_for_other_versions
        end
      end

      # Records the effect this flaw has on a given version of MPLAB X.
      # @api private
      def affects_version(version, effect)
        @versions[version] = effect
      end

      # Records the effect that this flaw probably has in other versions of
      # MPLAB X that have not been tested.  This allows us to record our guesses
      # about how the next version of MPLAB X will behave.
      # @api private
      def probably_affects_other_versions(effect)
        @probable_affect_for_other_versions = effect
      end
    end

    @flaw_hash = {}

    # Returns the {Flaw} with the specified name.
    # @param name [Symbol] The name of the flaw.  The names are listed in +flaws.rb+.
    # @return [Flaw]
    def self.[](name)
      @flaw_hash[name].effect Mplab.version
    end

    # @api private
    def self.add(name)
      @flaw_hash[name] = flaw = Flaw.new(name)
      yield flaw
    end

    add(:writing_tris_affects_output) do |flaw|
      flaw.affects_version '1.85', true
      flaw.affects_version '1.90', true
      flaw.affects_version '1.95', true
      flaw.affects_version '2.00', true
      flaw.affects_version '2.05', true
      flaw.affects_version '2.10', true
      flaw.probably_affects_other_versions false
    end

    add(:fr_memory_attach_useless) do |flaw|
      flaw.affects_version '1.85', false
      flaw.affects_version '1.90', false
      flaw.probably_affects_other_versions true
    end

    add(:firmware_cannot_write_user_id0) do |flaw|
      flaw.affects_version '1.85', true
      flaw.affects_version '1.90', true
      flaw.probably_affects_other_versions false
    end

    add(:adc_midrange) do |flaw|
      flaw.affects_version '1.85', :no_middle_values
      flaw.probably_affects_other_versions :bad_modulus
    end

    add(:instruction_inc_is_in_byte_units) do |flaw|
      flaw.affects_version '1.85', true
      flaw.affects_version '1.90', true
      flaw.affects_version '1.95', true
      flaw.affects_version '2.00', true
      flaw.probably_affects_other_versions false
    end
  end
end
