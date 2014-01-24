How MPLAB X is found
====

RPicSim uses many Java classes from MPLAB X.
This section describes how it finds those classes at run time.
The code that controls this can be found in `lib/rpicsim/mplab_x.rb` in the source code of RPicSim.

The primary thing that RPicSim needs to do is figure out what directory MPLAB X has been installed in.
If the `RPICSIM_MPLABX` environment variable is set, it will assume that environment variable contains the path to the MPLAB X directory.
The environment variable is useful because it allows you to copy the files from one version of MPLAB X to some alternative place on your computer and use that version of MPLAB X for your simulations while you continue to use other versions of MPLAB X for your actual firmware development.

If the environment variable is not present, RPicSim will look for the MPLAB X directory in a few standard places and choose the first one that exists.

After RPicSim finds the MPLAB X directory, it will look in various subdirectories for JAR files and add all of them to the Java classpath so that the Java classes in those JAR files can be used.