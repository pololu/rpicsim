// chip=18F25K50
#include <xc.h>
#include <stdint.h>

volatile uint8_t varRamU8;
volatile uint8_t varRamAbsU8 @ 0x500;
static volatile uint8_t varRamStaticAbsU8 @ 0x501;
const volatile uint16_t varCodeU16;
const volatile uint8_t varCodeBigArray[300];
const volatile uint16_t varCodeAbsU16 @ 0x1000 = 0x1234;
static const volatile uint16_t varCodeStaticAbsU16 @ 0x1002 = 0x5678;

void function1()
{
    TRISC = 0;
}

void main()
{
    function1();
}
