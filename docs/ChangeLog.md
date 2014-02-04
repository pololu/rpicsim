Change log
====

1.0.1
----

* {RPicSim::Pic#run_to}: Changed it so that the simulation will not take another step if the cycle limit has been reached.  This means that no steps will be run if the cycle limit is 0, which seems more natural than running one step.
* {RPicSim::ProgramFile#address_description}: Changed it to handle the case where the address is negative and return a negative decimal number instead of "0x..ff".  This matters if the value 0 is on the PIC stack because of `run_subroutine`.


1.0.0
----

This is the initial release.