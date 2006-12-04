# CSVFile 0.5.5 vs. FasterCSV vs. CSV

# 20061207

filename = '../test_data.csv'

require '../../../lib/csv_file'
start_time = Time.now
file = CSVFile.new(filename, :header_line, :none, 'r')
file.read
file.close
finish_time = Time.now
print 'CSVFile: '
puts csv_file_time_delta = finish_time - start_time

require '../faster_csv'
start_time = Time.now
FasterCSV.foreach(filename) do |row|
  # do nothing, we're just timing a read...
end
finish_time = Time.now
print 'FasterCSV: '
puts faster_csv_time_delta = finish_time - start_time

require 'csv'
start_time = Time.now
CSV.foreach(filename) do |row|
  # do nothing, we're just timing a read...
end
finish_time = Time.now
print 'CSV: '
puts csv_time_delta = finish_time - start_time
