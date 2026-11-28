# test/helper.rb

require 'minitest/autorun'
require 'minitest/mock'
require 'objspace'
require 'stringio'
require 'tmpdir'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'dsv'
