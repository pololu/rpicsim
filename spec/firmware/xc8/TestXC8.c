// chip=18F25K50
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
