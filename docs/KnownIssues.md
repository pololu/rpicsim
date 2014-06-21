Known issues
====

This page documents all the known issues RPicSim has that could affect its users.
Some issues are caused by the MPLAB X simulator and would need to be addressed by Microchip.

RPicSim has only been tested with the versions of MPLAB X that are listed on the {file:Introduction.md} page.
If you are using a different version of MPLAB X, you might have different issues.

Many of these issues have only been reproduced on a single model of PIC microcontroller and they may or may not affect other models.

Many of these issues are also reported on other pages of this {file:Manual.md manual}, but this page is a complete list of all issues that could affect users of RPicSim.

Internal issues that have been successfully worked around are not listed here, but might be found in the RPicSim specs by searching for the word "flaw".

There are almost certainly many issues that have not been found yet.


MPLAB X simulator does not support all PIC devices equally
----
_Type: MPLAB X missing feature_

Be sure to check the Device Support table to see if your device is properly supported by the MPLAB X simulator.
The table can be found in your MPLAB X installation folder under "`docs/Device Support.htm`".
The _SIMISA_ column probably stands for "Simulator (instruction set and architecture)" while the _SIMP_ column probably stands for "Simulator (peripherals)".


Simulation timing is affected by the details of how long each instruction takes
----
_Type: MPLAB X missing feature_

As mentioned on the {file:Running.md Running} page, RPicSim's only way to advance the simulation is to execute an entire instruction.
Some instructions take two instruction cycles to run and others only take one.
When you request RPicSim to delay for a certain number of cycles, it might need to delay by one cycle more than was requested since it cannot stop in the middle of a two-cycle instruction.
As a result, the timing of your tests and the input signals you send to the simulated device can sometimes be slightly off and these errors could accumulate in longer tests.

One workaround that prevents timing errors from accumulating is to only use {RPicSim::Sim#run_to_cycle_count} to run the simulation.


MPLAB X must be on the C drive
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

In Windows, a bug in MPLAB X prevents RPicSim from using an MPLAB X installed on any drive other than the C drive.

This issue is tested in `spec/mplab/path_retrieval_spec.rb`.


Firmware under test must be inside a folder named "dist"
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

This issue is tested in `spec/mplab/program_file_spec.rb`.


Cannot detect PIC model from COF file
----
_Type: RPicSim missing feature_

Currently RPicSim requires the user to always specify the PIC device name when creating a {RPicSim::ProgramFile} or a subclass of {RPicSim::Sim}, even though it might be possible to get that information from the COF file.


Variables defined in user ID space are not read from the COF file
----
_Type: MPLAB X bug_

_MPLAB X version affected: all tested versions_

If your firmware uses variables stored in user ID space, the workaround for this issue is to simply set any variables defined in user ID space to the correct values from Ruby before running the simulation.
This issue is tested in `spec/integration/program_memory_variable_spec.rb`.


Simulated firmware cannot write to the first user ID location
----
_Type: MPLAB X bug_

_MPLAB X versions affected: 1.85, 1.90_

This issue is tested in `spec/integration/program_memory_variable_spec.rb`.
It has been {http://www.microchip.com/forums/m743214.aspx reported to Microchip} and was fixed in later versions.


Pins report the wrong output state if the ANSELx bit is 1
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

The ANSELx bit for a real PIC pin only disables the digital input circuitry and should not affect the pin's use as a digital output.
However, if the ANSELx bit is set to 1, then {RPicSim::Pin#driving_low?} always seems to return true even if the pin is actually driving high.

This issue is tested in `spec/integration/pin_spec.rb`.


Pins report the wrong output state if LATx is set before TRISx
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

Updating a pin's LATx bit before its clearing its TRISx bit is the proper way to turn on an output pin without causing glitches.
However, if you set the two bits in that order then {RPicSim::Pin#driving_low?} always seems to return true even if the pin is actually driving high.

This issue is tested in `spec/integration/pin_spec.rb`.


Pins report the wrong output state if TRISx is cleared again
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

Even if you set up the pin properly (working around all the issues above) and get {RPicSim::Pin#driving_high?} to return true, a `bcf` instruction on the pin's TRISx bit (or probably any write to the TRISx register) will cause the pin to start reporting the wrong output state.

This issue is tested in `spec/integration/pin_spec.rb`.


RAM watcher is useless because all of RAM seems to change on every step
----
_Type: MPLAB X bug_

_MPLAB X versions affected: 1.95 and later_

This issue is tested in `spec/mplab/memory_attach_spec.rb`.
If you want to use the {file:RamWatcher.md RAM watcher}, you should use MPLAB X version 1.85 or 1.90.


RAM watcher reports a write to PORTA and LATA when LATA is written
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

The {file:RamWatcher.md RAM watcher}, when testing code that writes to LATA, might actually report both a write to LATA and a write to PORTA.
This issue has been observed on a PIC10F322 but it probably affects other PORTx and LATx registers on other devices.

This issue is tested in `spec/integration/ram_watcher_spec.rb`.
This issue could not be tested on MPLAB X versions affected by the "RAM watcher is useless" issue above.


RAM watcher reports extra writes on devices where registers have multiple addresses
----
_Type: RPicSim missing feature_

_MPLAB X versions affected: all tested verisons_

On certain devices, some registers are available at multiple addresses.
When the value of the register changes, the RAM watcher will report writes to each of the addresses that the register occupies, which makes the resulting hash large and hard to work with.

For example, on the PIC16F1459, PCL occupies the third byte of each of the 32 banks of RAM, so it
can be accessed no matter which bank is selected.
Whenever the program counter advances, the RAM watcher reports writes to all 32 addresses that PCL occupies.

One workaround is to write a helper function that filters uninteresting addresses out of the hash returned by the RAM watcher.

This issue is tested in `spec/integration/ram_watcher_spec.rb`.
This issue could not be tested on MPLAB X versions affected by the "RAM watcher is useless" issue above.


RAM watchers cannot be garbage collected until the end of the simulation
----
_Type: RPicSim missing feature_

_MPLAB X versions affected: all_

Any instance of {RPicSim::MemoryWatcher}, including RAM watchers, cannot be garbage collected until the associated {RPicSim::Sim} object gets garbage collected.
This is because some internal objects managed by the Sim class need to hold on to a reference to the RAM watcher in order to send updates to it.

Therefore, creating a large number of RAM watcher objects for a single simulation could cause performance problems.

This problem could be fixed in the future by using Ruby's WeakRef class to make weak references.


Midrange ADC gives incorrect readings
----
_Type: MPLAB X bug_

_MPLAB X versions affected: all tested versions_

The simulated ADC for midrange PIC microcontrollers has various issues in different versions of MPLAB X that make it give incorrect readings.
These issues might affect other PIC architectures as well.

* **Bad modulus:** In MPLAB X 1.90 and later, simply setting a pin to high with `pin.set(true)` will result in an ADC reading of 0.
  The workaround is to use `pin.set(4.9)`.
  The ADC acts like it is using a modulus operator incorrectly as a way of limiting the ADC result to be between 0 and 255.
* **No intermediate values:** In MPLAB X 1.85, setting a pin to any voltage other than 0 V will result in an ADC reading of 255.

These issues are tested in `spec/integration/adc_midrange_spec.rb`.  The bad modulus issue was {http://www.microchip.com/forums/m760886.aspx reported to Microchip} in November 2013.


Variables from XC8 are not correctly identified
----

RAM variables in programs using the XC8 compiler are often misidentified as being in program memory, and you need to get their address using {RPicSim::ProgramFile#symbols_in_program_memory}.
Some variables are not be identified at all, and you would have to write code to get their addresses from the SYM file.
