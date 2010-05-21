# CSVFile 0.9.2 vs. FasterCSV vs. CSV

# 2010.05.21, 22

filename = 'data.csv'

simple_csv_start_time = Time.now
#require 'Kernel/require_with_rbd'
#require 'SimpleCSV'
#require 'SimpleCSV-0.9.0.rbd/SimpleCSV'
#require 'SimpleCSV-0.9.1.rbd/SimpleCSV'
require 'Kernel/require_relative'
require_relative '../SimpleCSV'

# SimpleCSV.open(filename, :headers => true) do |csv_file|
#   csv_file.each do |row|
#     # p row
#   end
# end
SimpleCSV.foreach(filename, :headers => true) do |row|
  # p row
  # do nothing, we're just timing a read...
end
simple_csv_finish_time = Time.now


faster_csv_start_time = Time.now
require 'faster_csv'

# FasterCSV.open(filename, :headers => true) do |csv_file|
#   csv_file.each do |row|
#     # p row
#   end
# end
FasterCSV.foreach(filename, :headers => true) do |row|
  # p row
  # do nothing, we're just timing a read...
end
faster_csv_finish_time = Time.now


csv_start_time = Time.now
require 'csv'

CSV.foreach(filename) do |row|
  # p row
  # do nothing, we're just timing a read...
end
csv_finish_time = Time.now


print 'SimpleCSV: '
puts simple_csv_file_time_delta = simple_csv_finish_time - simple_csv_start_time

print 'FasterCSV: '
puts faster_csv_time_delta = faster_csv_finish_time - faster_csv_start_time

print 'CSV: '
puts csv_time_delta = csv_finish_time - csv_start_time
