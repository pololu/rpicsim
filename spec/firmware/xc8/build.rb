Dir.chdir(File.dirname(__FILE__)) # change working directory to this script's.
require 'fileutils'
system 'xc8 TestXC8.c --chip=18F25K50 -odist/TestXC8.cof --mode=free'
FileUtils.rm_rf 'funclist'
FileUtils.rm_rf 'l.obj'