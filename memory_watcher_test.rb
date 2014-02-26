# A quick and messy script that helps us see what writes are being
# reported by the RAM watcher when the CPU is executing NOPs.
# This helps to detect if there are more registers like PCL that
# we should be ignoring writes to.
#
# Run this with:  jruby -Ilib memory_watcher_test.rb

require 'rpicsim'
require 'pathname'

raise 'no' if RPicSim::Flaws[:fr_memory_attach_useless]

# There are bugs prevent us from testing these devices.
TroubledDevices = %w{
  PIC16F1527 PIC16F1704 PIC16F1708 PIC16LF1704 PIC16LF1708
  PIC18C601 PIC18C801
}

def supported_pic_devices
  Java::ComMicrochipCrownkingMplabinfo::mpPlatformTool.instance_eval do
    field_accessor :listOfDevices
  end
  sim_meta = com.microchip.mplab.mdbcore.platformtool.PlatformToolMetaManager.getTool("Simulator")
  devices = sim_meta.listOfDevices.to_a.uniq.sort
  devices = devices.grep(/PIC1[0268].*/)
  devices.select! do |device|
    sim_meta.getToolSupportForDevice(device).all? { |s| s && s.isSupported }
  end
  #devices = devices.drop_while { |d| d != TroubledDevices.last } # tmphax
  devices -= TroubledDevices
  devices
end

Pathname('spec/firmware/dist').mkpath
File.open('spec/firmware/dist/Zeros.hex', 'w') { |f| f.write <<END }
:020000040000FA
:1000000000000000000000000000000000000000F0
:1000100000000000000000000000000000000000E0
:1000200000000000000000000000000000000000D0
:1000300000000000000000000000000000000000C0
:1000400000000000000000000000000000000000B0
:1000500000000000000000000000000000000000A0
:100060000000000000000000000000000000000090
:100070000000000000000000000000000000000080
:00000001FF
END

devices = supported_pic_devices

File.open('output.txt', 'w') do |output|
  devices.each do |device|
    output.puts device
    puts device
    klass = Class.new(RPicSim::Sim)
    klass.instance_eval do
      device_is device
      filename_is 'spec/firmware/dist/Zeros.hex'
    end
    sim = klass.new
    
    ram_watcher = sim.ram_watcher
    sim.step
    #output.puts ram_watcher.writes.inspect
    ram_watcher.clear
    sim.step
    output.puts ram_watcher.writes.inspect
    output.puts
  end
end