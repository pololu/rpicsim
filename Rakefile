require 'pathname'
require 'fileutils'
require 'rspec/core/rake_task'

task "default" => "spec"

# Fix the annoying default behavior of the RSpec Rake task which is to
# put every last filename in the commandline.  It makes the test output
# needlessly verbose, especially if you are running the multispec task.
class RSpec::Core::RakeTaskBetter < RSpec::Core::RakeTask
  def files_to_run
    (ENV['SPEC'] || pattern) ? super : []
  end
end

RSpec::Core::RakeTaskBetter.new("spec") do |t, opts|
  t.pattern = nil
  
  if ENV["COVERAGE"] == 'Y'
    # TODO: figure out why adding -rspec/spec_helper to the ruby_opts here makes create_assembly fail
    t.ruby_opts = "--debug"
  end
end

desc "Run the specs and generate a code coverage report."
task "coverage" do
  ENV["COVERAGE"] = 'Y'
  Rake::Task['spec'].invoke
end

desc "Run the specs against multiple versions of MPLAB X."
task "multispec" do
  Dir.glob((mplab_x_bottles_path + "*").to_s).sort.each do |path|
    puts "Running specs against MPLAB X from #{path}"
    ENV['RPICSIM_MPLABX'] = path
    Rake::Task['spec'].invoke
    Rake::Task['spec'].reenable
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
  sh 'grep -ni todo -r lib spec docs'
end

task "spec" => "firmware"

desc "Compile the firmware used for the specs."
task "firmware"

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
  md = first_line.match %r{p([0-9A-Z]+)}
  if !md
    raise "Could not determine device from first line of #{asm_file}."
  end
  md[1]
end

asm_files = Dir.glob('spec/firmware/src/*.asm').map(&method(:Pathname))
raise 'No firmware found' if asm_files.empty?

asm_files.each do |asm_file|
  cof_file = asm_file.parent.parent + 'dist' + asm_file.sub_ext('.cof').basename
  file cof_file => asm_file do
    device = detect_device(asm_file)
    o_file = cof_file.sub_ext('.o')
    err_file = cof_file.sub_ext('.err')
    lst_file = cof_file.sub_ext('.lst')
    begin
      o_file.parent.mkpath
      sh %Q{#{mpasm_path} -p#{device} -q -l"#{lst_file}" -e"#{err_file}" -o"#{o_file}" "#{asm_file}"}
    rescue RuntimeError
      err_file = o_file.sub_ext(".err")
      if err_file.exist?
        $stderr.puts err_file.read
      else
        $stderr.puts "MPASM failed but the ERR file was not found: #{err_file}"
      end
      raise
    end
    sh %Q{#{mplink_path} -p#{device} -q -w -o"#{cof_file}" "#{o_file}"}
  end  
  task 'firmware' => cof_file
end

task 'firmware' => 'spec/firmware/BoringLoop.cof'

desc 'Clean up compiled firmware output files.'
task 'firmware:clean' do
  FileUtils.rm_r 'spec/firmware/dist', verbose: true
end

# Copy the COF file out of the dist directory so we can test that flaw in MPLAB X
file 'spec/firmware/BoringLoop.cof' => 'spec/firmware/dist/BoringLoop.cof' do
  FileUtils.cp 'spec/firmware/dist/BoringLoop.cof', 'spec/firmware/BoringLoop.cof', verbose: true
end