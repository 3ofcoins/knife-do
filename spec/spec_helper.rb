require 'pathname'

require 'chef'
require 'chef/knife'

require 'minitest/autorun'
require 'minitest/spec'
require 'wrong'
require 'wrong/adapters/minitest'

Wrong.config.alias_assert :expect, override: true
include Wrong

require 'knife-do'

lib = File.realpath(File.join(File.dirname(__FILE__), 'fixtures'))
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
