lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'knife-do/version'

Gem::Specification.new do |spec|
  spec.name = 'knife-do'
  spec.version = KnifeTasks::VERSION
  spec.authors = ['']
  spec.email         = ['']
  spec.description   = ''
  spec.summary       = ''
  spec.homepage      = 'https://github.com/3ofcoins/knife-do'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'chef'
  spec.add_dependency 'rake'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'debugger'
end

