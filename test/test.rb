# CSVFile 0.7.0 vs. FasterCSV vs. CSV

# 20100112

require 'File/relative_path'

filename = 'test_data.csv'

require File.relative_path('../lib/CSVFile')
start_time = Time.now
CSVFile.foreach(filename) do |row|
  # do nothing, we're just timing a read...
end
finish_time = Time.now
print 'CSVFile: '
puts csv_file_time_delta = finish_time - start_time

require 'faster_csv' # As of writing, at 1.5.0
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
