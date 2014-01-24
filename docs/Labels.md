Labels
====

It is sometimes helpful to make a {file:UnitTesting.md unit test} that only tests a small piece of your firmware instead of running the entire thing.
The first step to testing a small piece of code is to find out where it has been stored in program memory.
RPicSim makes this relatively easy by automatically processing the symbol table in your firmware's COF file.
Any symbol in program space is called a _label_ and RPicSim stores a {RPicSim::Label} object to represent it.

For an assembly program, RPicSim labels correspond to any assembly label defined in code space.  These will usually correspond to subroutines and goto targets but could also be variables stored in flash.

For a C program, RPicSim labels usually correspond to functions.

Getting a Label object
---

You will generally not need to work directly with {RPicSim::Label} objects; usually the only thing a test will need to do with a label is to specify its name as an argument to {RPicSim::Pic#goto}, {RPicSim::Pic#run_to}, or {RPicSim::Pic#run_subroutine}.

If you do want to get a Label object, then you can call {RPicSim::Pic#label} and pass it the name of the label as the first argument:

    !!!ruby
    pic.label(:loopStart)  # => returns a Label object

In MPASM, all labels are exported publicly by default, so they will all be available to RPicSim.

C compilers will generally put an underscore at the beginning of any labels they generate.  For example, to get the address of a C function named `foo`, you might have to access a label named `_foo` using code like this:

    !!!ruby
    pic.label(:_foo)

If RPicSim cannot find the label you want to use, you might troubleshoot it by printing out a list of all the known labels:

    !!!ruby
    p pic.class.program_file.labels.keys


Using a Label object
----

You can basically only do two things with a Label object:

* Get its name by calling {RPicSim::Label#name}.
* Get its address by calling {RPicSim::Label#address}.