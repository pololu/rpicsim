Labels
====

RPicSim automatically processes the symbol table in your firmware's COF file.
Any symbol in program space is called a _label_ and RPicSim stores a {RPicSim::Label} object to represent it.

For an assembly program, RPicSim labels correspond to any assembly label defined in code space.
These will usually correspond to subroutines and goto targets but could also be variables stored in program memory.
In firmware assembled by MPASM, all labels are exported publicly by default, so they will all be available to RPicSim.

For a C program, RPicSim labels usually correspond to functions.

Getting a Label object
---

To get a Label object, call {RPicSim::Sim#label} and pass it the name of the label as the first argument:

    !!!ruby
    sim.label(:loopStart)  # => returns a Label object

C compilers will generally put an underscore at the beginning of any labels they generate.
Therefore, to get the address of a C function named `foo`, you might have to access a label named `_foo` using code like this:

    !!!ruby
    sim.label(:_foo)

If RPicSim cannot find the label you want to use, you might troubleshoot it by printing out a list of all the known labels:

    !!!ruby
    p sim.labels.keys


Using a Label object
----

There are three main things you can do with a Label object:

* Get its name by calling {RPicSim::Label#name}.
* Get its address by calling {RPicSim::Label#address}.
* Pass it or its name as an argument to some of the methods for {file:Running.md running} the simulation.
