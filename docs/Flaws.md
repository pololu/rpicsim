Flaws
====

This page documents all the known flaws of RPicSim that could affect its users.
Some flaws are caused by the MPLAB X simulator and would need to be addressed by Microchip.

RPicSim has only been tested with the following versions of MPLAB X:

  * 1.85
  * 1.90
  * 1.95
  * 2.00

If you are using a different version of MPLAB X, some of the flaws might not apply to you.

Many of these flaws have only been tested for on a single model of PIC and they may or may not affect other models.

Many of these flaws are also reported on other pages of this {file:Manual.md manual}, but this page is complete list of all flaws that could affect users of RPicSim.

Internal flaws that have been successfully worked around are not listed here, but might be found in the RPicSim specs by searching for the word "flaw".

There are almost certainly many flaws that have not been found yet.


MPLAB X simulator does not support all PICs equally
----
_Type: MPLAB X missing feature_

Be sure to check the Device Support table to see if your PIC is properly supported by the MPLAB X simulator.
The table can be found in your MPLAB X installation folder under "`docs/Device Support.htm`".
The _SIMISA_ column probably stands for "Simulator (instruction set and architecture)" while the _SIMP_ column probably stands for "Simulator (peripherals)".


Simulation timing is affected by the details how long each instruction takes
----
_Type: MPLAB X missing feature_

As mentioned on the {file:Running.md Running} page, RPicSim's only way to advance the simulation is to execute an entire instruction.
Some instructions take two instruction cycles to run and others only take one.
When you request RPicSim to delay for a certain number of cycles, it might need to delay by one cycle more than was requested since it cannot stop in the middle of a two-cycle instruction.
As a result, the timing of your tests and the input signals you send to the simulated PIC can sometimes be slightly off and these errors could accumulate in longer tests.

One workaround that prevents timing errors from accumulating is to only use {RPicSim::Pic#run_to_cycle_count} to run the simulation.


MPLAB X must be on the C drive
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

In Windows, a bug in MPLAB X prevents RPicSim from using an MPLAB X installed on any drive other than the C drive.

This flaw is tested in `spec/mplab_x/path_retrieval_spec.rb`.


Firmware under test must be inside a folder named "dist"
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

This flaw is tested in `spec/mplab_x/program_file_spec.rb`.


Limited number of variable types supported
----
_Type: RPicSim missing feature_

There is no support for variables larger than 32 bits.
There is no support for arrays or structs of variables.
There is also no support for reading and writing directly from the simulated device's RAM, Flash, EEPROM, and stack memories from Ruby.

No EEPROM support
----
_Type: RPicSim missing feature_

RPicSim does not support reading or writing from EEPROM from Ruby.


Dissasembly is limited to midrange and baseline PICs
----
_Type: RPicSim missing feature_

The disassembled instruction graph created by {RPicSim::ProgramFile} currently only supports baseline and midrange PICs, but it should be easy to expand to other PICs.
This is a side feature of RPicSim, and not required for simulation.


Stack trace will show slightly wrong values for PIC18
----
_Type: RPicSim bug_

For the PIC18, {RPicSim::Pic#stack_trace} will probably show values that are too high by one because it does not account for the fact that PIC18 instructions take two bytes.


Cannot detect PIC model from COF file
----
_Type: RPicSim missing feature_

The MPLAB X code might allow RPicSim to detect the type of PIC used from the COF file so that the user does not have to specify it when creating a {RPicSim::ProgramFile} or a subclass of {RPicSim::Pic}.
Currently RPicSim requires the user to always specify the PIC model.


Not tested on Linux and Mac OS X
----
_Type: RPicSim missing feature_

RPicSim has not been tested on Linux and Mac OS X.  See {file:SupportedOperatingSystems.md Supported operating systems} for more information.


Variables defined in user ID space are not read from the COF file
----
_Type: MPLAB X bug_

_MPLAB X version affected: all tested versions_

The workaround is to simply set any variables defined in user ID space to the correct values from Ruby before running the simulation.
This flaw is tested in `spec/integration/flash_variable_spec.rb`.


Simulated firmware cannot write to the first user ID location
----
_Type: MPLAB X bug_

_MPLAB X versions affected: 1.85, 1.90_

This flaw is tested in `spec/integration/flash_variable_spec.rb`.
It has been {http://www.microchip.com/forums/m743214.aspx reported to Microchip} and was fixed in later versions.


Pins report the wrong output state if the ANSELx bit is 1
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

The ANSELx bit for a real PIC pin only disables the digital input circuitry and should not affect the pin's use as a digital output.
However, if the ANSELx bit is set to 1, then {RPicSim::Pin#driving_low?} always seems to return true even if the pin is actually driving high.

This flaw is tested in `spec/integration/pin_spec.rb`.


Pins report the wrong output state if LATx is set before TRISx
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

Setting a pin's LATx bit before its clearing its TRISx bit is the proper way to turn on an output pin without causing glitches.
However, if you set the two bits in that order then {RPicSim::Pin#driving_low?} always seems to return true even if the pin is actually driving high.

This flaw is tested in `spec/integration/pin_spec.rb`.


Pins report the wrong output state if TRISx is cleared again
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

Even if you set up the pin properly (working around all the flaws above) and get {RPicSim::Pin#driving_high?} to return true, a `bcf` instruction on the pin's TRISx bit (or probably any write to the TRISx register) will cause the pin to start reporting the wrong output state.

This flaw is tested in `spec/integration/pin_spec.rb`.


RAM watcher is useless because all of RAM seems to change on every step
----
_Type: MPLAB X bug_

_MPLAB X versions affected: 1.95, 2.00_

This flaw is tested in `spec/mplab_x/memory_attach_spec.rb`.
If you want to use the {file:RamWatcher.md RAM watcher}, you should use MPLAB X version 1.85 or 1.90.


RAM watcher reports a write to PORTA instead of to LATA
----
_Type: MPLAB X bug_

_MPLAB X verisons affected: all tested versions_

The {file:RamWatcher.md RAM watcher}, when testing code that writes to LATA, might actually report it as a write to PORTA instead of LATA.
This flaw has been observed on a PIC10F322 but it probably affects other PORTx and LATx registers.

This flaw is tested in `spec/integration/ram_watcher_spec.rb`.  This flaw could not be tested on MPLAB X versions affected by the "RAM watcher is useless" flaw above.


Midrange ADC gives incorrect readings
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

The simulated ADC for midrange PICs has various flaws in different versions of MPLAB X that make it give incorrect readings.  These flaws might affect other PIC architectures as well.

* **Bad modulus:** In MPLAB X 1.90 and later, simply setting a pin to high with `pin.set(true)` will result in an ADC reading of 0.
  The workaround is to use `pin.set(4.9)`.
  The ADC acts like it is using a modulus operator incorrectly as a way of limiting the ADC result to be between 0 and 255.
* **No intermediate values:** In MPLAB X 1.85, setting a pin to any voltage other than 0 V will result in an ADC reading of 255.

These flaws are tested in `spec/integration/adc_midrange_spec.rb`.  The bad modulus flaw was {http://www.microchip.com/forums/m760886.aspx reported to Microchip} in November 2013.

