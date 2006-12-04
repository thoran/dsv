# Test CSVFile

# 20061203
# 0.5.0

# Changes since 0.4: 

#@debug = true
@debug = false

require 'pp' if @debug
require '../lib/csv_file'

in_filename = '0.csv'

in_file = CSVFile.new(in_filename, true, :double, 'r+')
in_file.read
in_file.write_csv('name', 'phone')
in_file.close
