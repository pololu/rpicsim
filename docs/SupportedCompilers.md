# Supported compilers

RPicSim supports any compiler that can generate a standard Microchip COF or ELF file that is recognized by the file loading code in MPLAB X.  If your compiler does not generate such a file, then you could use an Intel HEX file instead, but then RPicSim will not automatically have access to your firmware's symbol table, so it will not know where variables, functions, and labels are located.

RPicSim has been extensively tested with COF files produced by MPASM, and the ELF files produced by XC8.  It also has support for reading symbols from the SYM file produced by XC8.  At the time of this writing, it has not been tested with C18.