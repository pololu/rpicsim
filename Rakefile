require 'pathname'
require 'fileutils'
require 'rspec/core/rake_task'

task "default" => "spec"

# This class probably only works with RSpec 3.1.x.
class RSpec::Core::RakeTaskBetter < RSpec::Core::RakeTask
  def spec_command
    cmd_parts = []
    cmd_parts << (rspec_command || default_rspec_command)
    cmd_parts << file_inclusion_specification
    cmd_parts << file_exclusion_specification
    cmd_parts << rspec_opts
    cmd_parts.flatten.reject(&blank).join(' ')
  end

  attr_accessor :rspec_command

  def default_rspec_command
    'rspec'
  end
end

$rspec_task = RSpec::Core::RakeTaskBetter.new("spec") do |t, opts|
  t.pattern = 'spec'

  if ENV["COVERAGE"] == 'Y'
    t.ruby_opts = "--debug"
  end

  # It would be nice to add the following line here, but somehow it
  # makes MPLAB X assembly code fail:
  # t.ruby_opts = '-rspec/spec_helper'
end

# After running specs, clean up the log files that MPLAB X makes.
Rake::Task['spec'].enhance do
  FileUtils.rm Dir.glob 'MPLABXLog.xml*'
end

def run_specs(mplabx_path, rspec_version)
  puts "Running specs with RSpec #{rspec_version} and #{mplabx_path}"
  $rspec_task.rspec_command = "jruby ./spec/rspec_runner.rb \"~> #{rspec_version}\""
  ENV['RPICSIM_MPLABX'] = mplabx_path
  Rake::Task['spec'].reenable
  Rake::Task['spec'].invoke
  puts
end

desc "Run the specs and generate a code coverage report."
task "coverage" do
  ENV["COVERAGE"] = 'Y'
  Rake::Task['spec'].invoke
end

desc "Run the specs against multiple versions of MPLAB X and RSpec."
task "multispec" do
  mplabx_paths = Dir.glob((mplab_x_bottles_path + "*").to_s).sort.reverse
  rspec_versions = %w{ 3.3.0 3.2.0 3.1.0 3.0.0 2.99.0 2.14.1 }

  # First, test against each bottled version of MPLAB X.
  # Presumably this will be using a 3.x version of RSpec.
  #mplabx_paths.each do |path|
  #  run_specs path, rspec_versions.first
  #end

  # Next, test against each version of RSpec, using the latest bottled version
  # of MPLAB X.
  rspec_versions.each do |version|
    run_specs mplabx_paths.first, version
  end
end

desc "Print out lines of code and related statistics."
task "stats" do
  puts "Lines of code and comments (including blank lines):"
  sh "find lib -type f | xargs wc -l"
  puts
  puts "Words of documentation:"
  sh "find docs -type f | xargs wc -w"
end

desc 'Print TODO items from the source code'
task 'todo' do
  sh 'grep -ni todo -r lib spec docs || echo none', verbose: false
end

task "spec" => "firmware"

desc 'Compile any firmware that is not stored in git.'
task 'firmware' => 'firmware:mpasm'

desc 'Compile MPASM firmware'
task 'firmware:mpasm'

desc 'Generate documentation with YARD'
task 'doc' => 'Introduction.md' do
  sh 'yard'
end

task 'Introduction.md' do
  # NOTE: YARD supports Github-flavored markdown by default but not under JRuby, because
  # the redcarpet gem has a C extension.
  puts 'Converting README.md (Github-flavored markdown) to Introduction.md (for YARD)'
  readme = File.open('README.md', 'r:UTF-8') { |f| f.read }
  readme.gsub! %r{</?sup>}i, ''
  readme.gsub! %r{^```(\w+)\n(.*?)\n```\n}m do |matched_str|
    language, code = $1, $2
    ("!!!#{language}\n" + code).gsub(/^/, '    ') + "\n"
  end
  readme.gsub! %r{<github>(.+?)</github>}m, ''
  readme << "This page is part of {file:Manual.md the RPicSim manual}.\n" +
    "For API documentation, click the \"Index\" link at the top of this page."
  File.open('Introduction.md', 'w:UTF-8') { |f| f.write readme }
end

desc 'Build the gem'
task 'build' => 'Introduction.md' do
  sh 'gem build rpicsim.gemspec'
end

def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable? exe
    end
  end
  return nil
end

def mpasm_path
  @mpasm_path ||= begin
    mpasm = ENV['RPICSIM_MPASM']

    mpasm ||= [
      ('mpasmx' if which('mpasmx')),
      ('mpasm' if which('mpasm')),
      'C:\Program Files (x86)\Microchip\MPLABX\mpasmx\mpasmx.exe',
      'C:\Program Files\Microchip\MPLABX\mpasmx\mpasmx.exe',
      '/opt/microchip/mplabx/mpasmx/mpasmx',
      '/Applications/microchip/mplabx/mpasmx/mpasmx',
    ].find do |mpasm|
      mpasm && File.exist?(mpasm)
    end

    if !mpasm
      raise "Cannot find MPASM or MPASMX executable.  Please put it on your path or set the RPICSIM_MPASM environment variable to its full path."
    end

    if !File.exist?(mpasm)
      raise "MPASM executable does not exist: #{mpasm}"
    end

    mpasm
  end
end

def mplink_path
  @mplink_path ||= begin
    mplink = ENV['RPICSIM_MPASM']

    mplink ||= [
      ('mplink' if which('mplink')),
      'C:\Program Files (x86)\Microchip\MPLABX\mpasmx\mplink.exe',
      'C:\Program Files\Microchip\MPLABX\mpasmx\mplink.exe',
      '/opt/microchip/mplabx/mpasmx/mplink',
      '/Applications/microchip/mplabx/mpasmx/mplink',
    ].find do |mplink|
      mplink && File.exist?(mplink)
    end

    if !mplink
      raise "Cannot find MPLINK executable.  Please put it on your path or set the RPICSIM_MPLINK environment variable to its full path."
    end

    if !File.exist?(mplink)
      raise "MPLINK executable does not exist: #{mplink}"
    end

    mplink
  end
end

def mplab_x_bottles_path
  @mplab_x_bottles_path ||= begin
    path = ENV['RPICSIM_MPLABX_BOTTLES']

    path ||= [
      "~/MPLABX",
      "C:/MPLABX"
    ].find do |p|
      p && File.directory?(p)
    end

    if !path
      raise "Cannot find MPLAB X bottles directory.  You can specify where it is using the RPICSIM_MPLABX_BOTTLES environment variable."
    end

    if !File.directory?(path)
      raise "MPLAB X bottles directory does not exist: #{path}."
    end

    Pathname(path)
  end
end

# Detects a device string like "10F322" from the first line of the ASM file.
def detect_device(asm_file)
  first_line = File.open(asm_file, 'r') { |f| f.readline }
  md = first_line.match %r{(p|chip=)([0-9A-Za-z]+)}
  if !md
    raise "Could not determine device from first line of #{asm_file}."
  end
  md[2]
end

# err_file should be a Pathname object to an MPASM .err file.
# When the compilation goes wrong, we want to print out the .err file.
def display_err_file(err_file)
  if err_file.exist?
    $stderr.puts err_file.read
  else
    $stderr.puts "MPASM failed but the ERR file was not found: #{err_file}"
  end
end

def mpasm(options, o_file)
  err_file = o_file.sub_ext('.err')

  original_mtime = o_file.exist? ? o_file.mtime : nil

  command = "#{mpasm_path} #{options}"
  begin
    sh command
  rescue RuntimeError
    display_err_file(err_file)
    raise
  end

  # Unfortunately, the error handling above does not work in Linux because
  # MPASMX for Linux always has a process return code of 0.
  # Instead, we check to see if the .o file has been changed.
  if !o_file.exist? || original_mtime == o_file.mtime
    display_err_file(err_file)
    raise 'MPASM error.'
  end
end

asm_files = Dir.glob('spec/firmware/mpasm/*.asm').map(&method(:Pathname))
raise 'No MPASM firmware found' if asm_files.empty?
asm_files.each do |asm_file|
  cof_file = asm_file.parent.parent + 'mpasm' + 'dist' + asm_file.sub_ext('.cof').basename
  file cof_file => asm_file do
    device = detect_device(asm_file)
    o_file = cof_file.sub_ext('.o')
    err_file = o_file.sub_ext('.err')
    lst_file = o_file.sub_ext('.lst')
    o_file.parent.mkpath
    mpasm %Q{-p#{device} -q -l"#{lst_file}" -e"#{err_file}" -o"#{o_file}" "#{asm_file}"}, o_file
    sh %Q{#{mplink_path} -p#{device} -q -w -o"#{cof_file}" "#{o_file}"}
  end
  task 'firmware:mpasm' => cof_file
end

desc 'Clean up compiled MPASM output files.'
task 'firmware:mpasm:clean' do
  FileUtils.rm_rf 'spec/firmware/mpasm/dist', verbose: true
end

# Copy the COF file out of the dist directory so we can test that flaw in MPLAB X
task 'firmware:mpasm' => 'spec/firmware/mpasm/BoringLoop.cof'
file 'spec/firmware/mpasm/BoringLoop.cof' => 'spec/firmware/mpasm/dist/BoringLoop.cof' do
  FileUtils.cp 'spec/firmware/mpasm/dist/BoringLoop.cof',
    'spec/firmware/mpasm/BoringLoop.cof', verbose: true
end

desc 'Compile all firmware'
task 'firmware:all' => ['firmware:mpasm', 'firmware:xc8']

desc 'Compile all XC8 firmware'
task 'firmware:xc8'

xc8_files = Dir.glob('spec/firmware/xc8/*.c').map(&method(:Pathname))
raise 'No XC8 firmware found' if xc8_files.empty?
xc8_files.each do |xc8_file|
  hex_file = xc8_file.parent.parent + 'xc8' + 'dist' + xc8_file.sub_ext('.hex').basename
  file hex_file => xc8_file do
    device = detect_device(xc8_file)
    map_file = hex_file.sub_ext('.map')
    hex_file.parent.mkpath
    sh "xc8 #{xc8_file} --chip=#{device} -O#{hex_file} -M#{map_file} --mode=free"
  end
  Rake::Task['firmware:xc8'].enhance [hex_file]
end

desc 'Delete compiled XC8 output files.'
task 'firmware:xc8:clean' do
  FileUtils.rm_rf 'spec/firmware/xc8/dist', verbose: true
end
