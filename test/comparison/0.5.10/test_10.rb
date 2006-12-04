# Test CSVFile 0.5.10

# 20070422

require '../../../lib/10'

filename = '../test_data.csv'
start_time = Time.now
file = CSVFile.readlines(filename)
finish_time = Time.now
print 'CSVFile: '
puts csv_file_time_delta = finish_time - start_time
require 'pp'; pp file
