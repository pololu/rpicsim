/** This is a C program that we compile with XC8 to make sure that
 RPicSim is compatible with XC8.
 The output is used in RPicSim's speds.
 It is built with build.rb and the output COF file is committed to GIT so that
 RPicSim contributors do not have to install XC8 themselves. **/
 
#include <xc.h>
#include <stdint.h>

volatile uint8_t ramVarUint8 @ 0x500;

static volatile uint8_t staticRamVarUint8 @ 0x501;

const volatile uint16_t flashVarUint16 @ 0x1000 = 0x1234;

static const volatile uint16_t staticFlashVarUint16 @ 0x1002 = 0x5678;

void function1()
{
    TRISC = 0;
}

void main()
{
    function1();
}