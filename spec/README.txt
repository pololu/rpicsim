This file explains the structure of our tests.

unit directory:
  These are the unit tests.  Each test just tests the contents of a single class
  or file.  These tests should definitely not make any calls to the MPLAB X
  classes.  Any dependencies should be simulated with mocks.
  
integration directory:
  These are the integration tests.  These tests will test code from more than
  one place.  These tests usually test multiple RPicSim classes and make sure
  they work properly with the MPLAB X classes.

mplab_x directory:
  These are the MPLAB X tests.  They test the MPLAB X classes to make sure they
  are fit for various purposes.  For example, if you wanted to make sure that
  the ADC simulation on the PIC10F322 behaves properly, you might want to add a
  test here.

example directory:
  This directory contains specs written to test out something so we can be sure
  it works before putting it in the documentation.  Usually the code from these
  specs is duplicated in the documentation, so be sure to change it in both
  places if you need to change it.

firmware directory:
  This directory contains assembly firmware source code (.asm) files.  These
  are automatically compiled into COF files when you run "rake" and these files
  are loaded by the integration and mplab tests.  Each firmware file has a
  corresponding class that is defined in firmware.rb.

Some tests indicate a flaw or problem with the system.  Usually these flaws are
the fault of the MPLAB X code.  These tests are marked with the "flaw: true"
metadata.  The tests should be adapted to pass when run against any supported
version of MPLAB X.  This means that some tests know about the flaws and adapt
their expectations accordingly.