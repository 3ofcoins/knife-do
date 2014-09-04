# -*- mode: ruby; coding: utf-8 -*-

require 'chef'
require 'chef/knife'

require 'rake/testtask'

libdir = File.realpath(File.join(File.dirname(__FILE__), 'lib'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

Rake::TestTask.new :spec do |task|
  task.libs.push %w(lib spec)
  task.test_files = FileList['spec/**/*_spec.rb', 'spec/fixtures/*.rb']
  task.verbose = true
end

task default: [:spec]
