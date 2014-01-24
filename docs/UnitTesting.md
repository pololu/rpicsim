Unit Testing
====

A _unit test_ is a test for a relatively small piece of a code, which tests that code in isolation from the other code in the application.
Unit testing is simply the practice of writing and running units tests to go along with your code.

The {file:Running.md Running page} explains how to run small portions of your code using RPicSim.
RPicSim allows you to access {file:Variables.md variables} and {file:SFRs SFRs}, so you can put the PIC into the desired state before running the code and then test that the PIC is in the right state after the code has executed.
RPicSim can also be used for {file:Stubbing.md stubbing subroutines} so that you can simply test the behavior of one subroutine instead of all the subroutines it calls.