# Supported PICs

RPicSim aims to support all 8-bit PICs.  No support is planned for 16-bit or 32-bit PICs because the author does not have an interest in using those devices.  It might be easy to add support for them, but the code that handles {file:SFRs.md SFRs} would have to be adjusted to allow SFRs with more than 8 bits.

RPicSim relies on MPLAB X code to perform the actual simulation and MPLAB X abstracts away most of the differences between PICs.

The 8-bit PICs have {http://www.microchip.com/pagehandler/en-us/family/8bit/architecture/home.html four different architectures}:

- Baseline
- Midrange
- Enhanced Midrange
- PIC18

There is currently some code in the {RPicSim::ProgramFile#instruction} that only work with baseline and midrange PICs, but it should be easy to expand it to other PICs.  This code is only used to calculate call stack depth information for users who want that feature; it is not used for actual simulations.