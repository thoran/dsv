# CSVFile 0.9.1 vs. FasterCSV vs. CSV

# 2010.05.21

filename = 'test_data.csv'

require 'Kernel/require_with_rbd'
require 'SimpleCSV'
start_time = Time.now
CSVFile.foreach(filename, :header_line => true) do |row|; end
CSVFile.read(filename)
finish_time = Time.now
print 'CSVFile: '
puts csv_file_time_delta = finish_time - start_time

require 'faster_csv'
start_time = Time.now
FasterCSV.foreach(filename) do |row|; end
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
