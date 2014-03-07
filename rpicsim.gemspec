# This file was written by hand.

require_relative "lib/rpicsim/version"

Gem::Specification.new do |s|
  s.name = 'rpicsim'
  s.version  = RPicSim::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')

  # The summary should be the same as the description at https://github.com/pololu/rpicsim
  s.summary = 'RPicSim provides an interface to the MPLAB X PIC simulator that allows you to write simulator-based automated tests of PIC firmware with Ruby and RSpec.'
  #s.description = ""
  s.homepage = 'https://github.com/pololu/rpicsim'

  s.authors = ['Pololu']
  s.license = 'MIT'

  s.required_rubygems_version = Gem::Requirement.new('>= 2')
  s.requirements << 'JRuby'
  s.requirements << 'MPLAB X'

  s.files = Dir['lib/**/*.rb', 'Introduction.md', 'LICENSE.txt', '*.md', 'Gemfile', 'docs/*', '.yardopts']
end