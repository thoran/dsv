#!/usr/bin/env ruby
# profile.rb

# 20111123

require 'ruby-prof'
require 'SimpleCSV.rbd/SimpleCSV'

TEST_DATA_PATH = File.join(File.dirname(__FILE__), 'test_data.csv')

RubyProf.start
SimpleCSV.read(TEST_DATA_PATH)
result = RubyProf.stop
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, 0)
