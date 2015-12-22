require File.join(File.dirname(__FILE__), 'lib', 'tilia', 'uri', 'version')
Gem::Specification.new do |s|
  s.name        = 'tilia-uri'
  s.version     = Tilia::Uri::Version::VERSION
  s.licenses    = ['BSD-3-Clause']
  s.summary     = 'Port of the sabre-uri library to ruby'
  s.description = 'Functions for making sense out of URIs.'
  s.author      = 'Jakob Sack'
  s.email       = 'tilia@jakobsack.de'
  s.files       = `git ls-files`.split("\n")
  s.homepage    = 'https://github.com/tilia/tilia-uri'
  s.add_runtime_dependency 'activesupport', '~> 4.2'
end
