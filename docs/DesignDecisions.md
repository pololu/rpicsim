Design decisions
====


Why use JRuby?
----
[Ruby](https://www.ruby-lang.org/) is a great, versatile programming language and it is a pleasure to work in.
The Ruby community has produced many books, blog posts, and online tutorials about Ruby.
Many questions about Ruby and RSpec are answered within minutes on [StackOverflow](http://www.stackoverflow.com).

[JRuby](http://jruby.org) is a Java implementation of the [Ruby programming language](https://www.ruby-lang.org/).
Since it runs on the Java Virtual Machine (JVM), JRuby programs can easily access the Microchip Java classes, which do the real work of simulating the PIC microcontroller.

Unlike many other languages on the JVM, JRuby doesn't require compilation.
This means you don't need to worry about juggling Makefiles and IDEs while you are writing your tests.
Checking out your latest commit from version control is all that is needed to ensure you are running the latest tests.


Why use RPicSim instead of just accessing the Microchip classes directly?
----
The Microchip classes are mostly undocumented and are complicated to use.
With Ruby and RPicSim, we can have a simple, intuitive domain-specific language (DSL) for dealing with PIC simulations.
Also, by writing your tests with RPicSim there is some hope that you will be shielded from future changes in the MPLAB X code.


Why use RSpec?
----
RSpec provides great ways to combine code from similar tests, provides good error messages, and encourages you to specify exactly what you are testing.
It is popular in the Ruby community.


Why not use SCL?
----
Microchip's [Stimulus Control Language (SCL)](http://www.microchip.com/forums/m111255.aspx) serves a lot of the same purposes as RPicSim.
It can simulate an external stimulus being applied to pins of a device and see how it behaves.
MPLAB X has a button in the "Stimulus" pane for attaching an SCL script to a simulation.

I have not used SCL and don't know much about it, but I think the main reasons to not use SCL are:

* It seems like SCL does not have several features required for unit tests, such as reading and writing the internal state of the simulated device.
* SCL does not appear to have functions or subroutines.
* SCL has been around since at least 2005, but as of January 2014, it seems to not be officially documented.
  The only documentation I could find is in the form of a few long forum posts at the top of the [MPLAB Simulator forum](http://www.microchip.com/forums/f18.aspx).


Why use a special Unicode character in the name of {RPicSim::Sim#run_µs}?
----
That name is just an alias.
You can use `run_microseconds` if you prefer.
While `run_µs` is hard to type, it is easier to read and I think code is read more than it is written.


Why not use Textile?
----
Textile was not used as a markup language for the documentation because I could not figure out how to easily have Ruby syntax highlighting.


How are RPicSim version numbers chosen?
----

RPicSim mostly attempts to use {http://semver.org/ semantic versioning 2.0.0} for its version numbers, except that the "public API" of RPicSim has not officially been defined yet.
Nothing from the {RPicSim::MPLABX MPLABX} module should be considered public.
Any method that Ruby considers to be public, and which also has a documentation string above its definition in the source, can probably be considered part of the public API, but we are not ready to commit to that yet.
At some point, the public API should be carefully defined and documented.

* * *

_This page was written by David Grayson, the main author of RPicSim._