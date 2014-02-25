# Supported devices

RPicSim aims to support all 8-bit PIC microcontrollers.
No support is planned for 16-bit or 32-bit PIC microcontrollers because we do not have an interest in using those devices.
It might be easy to add support for them, but the code that handles {file:SFRs.md SFRs} would have to be adjusted to allow SFRs with more than 8 bits.

RPicSim relies on MPLAB X code to perform the actual simulation, and MPLAB X abstracts away most of the differences between PICs.