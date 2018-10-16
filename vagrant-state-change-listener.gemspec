lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-state-change-listener/version'

Gem::Specification.new do |s|
  s.name            = 'vagrant-state-change-listener'
  s.version         = VagrantPlugins::StateChangeListener::VERSION
  s.platform        = Gem::Platform::RUBY
  s.date            = '2018-10-01'
  s.description     = 'Vagrant plugin for listening vm state changes and executing actions on changes'
  s.summary         = s.description
  s.homepage        = 'https://github.com/pr3sto/vagrant-state-change-listener'
  s.license         = 'MIT'

  s.authors         = ['Alexey Chirukhin']
  s.email           = 'pr3sto1377@gmail.com'

  s.files           = `git ls-files`.split($\)
  s.executables     = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files      = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths   = ['lib']

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
end
