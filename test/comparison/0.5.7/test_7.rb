# Test CSVFile 0.5.7

# 20070302

require '../../../lib/7'

filename = '../test_data.csv'
start_time = Time.now
file = CSVFile.new(filename, :header_line, :none, 'r')
file.read
file.close
finish_time = Time.now
print 'CSVFile: '
puts csv_file_time_delta = finish_time - start_time
