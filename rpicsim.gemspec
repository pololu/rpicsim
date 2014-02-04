# This file was written by hand.

require_relative "lib/rpicsim/version"

Gem::Specification.new do |s|
  s.name = 'rpicsim'
  s.version  = RPicSim::VERSION
  s.date = '2014-01-22'
  s.summary = 'RPicSim provides an interface to the MPLAB X PIC simulator that allows you to write simulator-based automated tests of PIC firmware.'
  #s.description = ""
  #s.homepage = ""

  s.authors = ['David Grayson']
  s.email = 'davidegrayson@gmail.com'
  s.license = 'MIT'

  s.required_rubygems_version = Gem::Requirement.new('>= 2')
  s.requirements << 'JRuby'
  s.requirements << 'MPLAB X'
  s.metadata['allowed_push_host'] = 'pololu.com'

  s.files = Dir['lib/**/*.rb', 'Introduction.md', 'LICENSE.txt', '*.md', 'Gemfile', 'docs/*', '.yardopts']
end