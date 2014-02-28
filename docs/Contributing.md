Contributing
====

RPicSim is hosted on the [pololu/rpicsim github page](https://github.com/pololu/rpicsim).

To report a bug, go to the github page and create a new issue.

If you want to contribute code, these are the general steps:

1. Clone our git repository to your computer.
2. Install JRuby and MPLAB X if you have not done so already.
3. Run these commands to get the development dependencies:

        jgem install bundler
        bundle
        
4. Run the specs with the command `bundle exec rake` to make sure they are working.
5. Add a new spec somewhere in the `spec` directory for the bug or feature you want to fix.
6. Run the specs again to make sure your spec is failing.
7. Modify the code.
8. Run the specs again to make sure they are all passing.
9. Fork our repository on github and push your changes to a branch of your repository.  It is good practice make a branch with a special name and push to that instead of master.
10. On github, make a pull request from your branch to our repository.

You can generate documentation from the source code by running:

    bundle exec rake doc

If you have multiple versions of Ruby installed it is good to keep just one version of Ruby on your PATH at any given time so you do not accidentally run the wrong version.
    
