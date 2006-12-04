# Test CSVFile

# 20061205
# 0.5.3

# Changes since 0.4: 
# 1. Nothing significant so far...  Just doing some refactoring.  
# 2. Just doing reads so as to optimise this some for speed.  

#@debug = true
@debug = false

$profile = true

require 'pp' if @debug
require '../lib/csv_file'

in_filename = '3.csv'

in_file = CSVFile.new(in_filename, true, :double, 'r+')
in_file.read
