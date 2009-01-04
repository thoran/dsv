# Test CSVFile

# 20090104

@debug = true
require 'pp' if @debug
@profile = false
require 'profile' if @profile

require File.expand_path(File.dirname(__FILE__) + '/../lib/CSVFile')

in_filename = 'test.csv'
in_file = CSVFile.new(in_filename, :read_only)
#pp in_file.read
#in_file.read_csv

# in_file.each{|line| pp line}
# pp in_file.lines[0].keys
# pp in_file.attributes
# pp in_file.headers
# 
# pp in_file.collect{|line| line[:name]}

#CSVFile.open(in_filename) do |csv_file|
#  csv_file.each{|line| pp line}
#end
#pp CSVFile.read(in_filename)

CSVFile.each(in_filename){|line| pp line}
