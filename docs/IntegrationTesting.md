Integration testing
====

An _integration test_ is a test for a relatively large system that helps ensure that different modules and routines can work properly together.
The structure of your integration tests is up to you, but a typical integration test in RPicSim should probably have these properties:

* It runs the simulation from the beginning of the code (address 0).
* It gets the simulation into the desired state by manipulating its input pins rather than directly modifying its RAM.
* It tests that the firmware did the right thing by checking the states of the output pins.
* It does not alter the program counter except perhaps to make the tests faster, as discussed in the {file:Stubbing.md Stubbing page}.
* It might use {RPicSim::Pic#every_step} to check certain assertions after every step of the simulation.  For example, it could test that a certain SFR's value never changes after it has been initialized.
* It might directly modify the device's EEPROM or flash memory at the beginning of the simulation if that memory is used to store settings.

For an example of an integration test, see the {file:Pins.md#label-PinMirror+example PinMirror example} from the Pins page.

