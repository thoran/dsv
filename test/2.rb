# Test CSVFile

# 20061205
# 0.5.2

# Changes since 0.4: 
# 1. Nothing significant so far...  Just doing some refactoring.  

#@debug = true
@debug = false

require 'pp' if @debug
require '../lib/csv_file'

in_filename = '2.csv'

in_file = CSVFile.new(in_filename, true, :double, 'r+')
in_file.read
in_file.write_csv('name', 'phone')
in_file.close
