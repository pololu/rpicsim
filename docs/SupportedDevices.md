# Supported devices

RPicSim aims to support all 8-bit PIC microcontrollers.  No support is planned for 16-bit or 32-bit PIC microcontrollers because the author does not have an interest in using those devices.

RPicSim relies on MPLAB X code to perform the actual simulation, and MPLAB X abstracts away most of the differences between PICs.

The 8-bit PICs have {http://www.microchip.com/pagehandler/en-us/family/8bit/architecture/home.html four different architectures}:

- Baseline
- Midrange
- Enhanced Midrange
- PIC18

There is currently some code in {RPicSim::ProgramFile#instruction} that only works with baseline and midrange PICs, but it should be easy to expand it to other PICs.  This code is only used to calculate call stack depth information for users who want that feature; it is not used for actual simulations.