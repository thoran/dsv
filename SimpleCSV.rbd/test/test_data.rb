# SimpleCSV 0.9.3 vs. FasterCSV vs. CSV

# 2010.05.26

filename = 'data.csv'

simple_csv_start_time = Time.now
#require 'SimpleCSV'
#require 'SimpleCSV-0.9.0.rbd/SimpleCSV'
#require 'SimpleCSV-0.9.1.rbd/SimpleCSV'
#require 'SimpleCSV-0.9.2.rbd/SimpleCSV'
require 'SimpleCSV.rbd/SimpleCSV'

# SimpleCSV.open(filename, :headers => true) do |csv_file|
#   csv_file.each do |row|
#     # p row
#   end
# end
#SimpleCSV.foreach(filename, :headers => false) do |row|
SimpleCSV.foreach(filename, :headers => true) do |row|
#SimpleCSV.foreach(filename, :headers => true, :as_array => true) do |row|
#SimpleCSV.foreach(filename, :headers => true, :quote => :mixed) do |row|
#SimpleCSV.foreach(filename, :headers => true, :quote => :mixed, :as_array => true) do |row|
#SimpleCSV.foreach(filename, :headers => true, :quote => :double) do |row|
  # p row
  # row.each{|e| puts e}
  # or
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
#FasterCSV.foreach(filename, :headers => false) do |row|
FasterCSV.foreach(filename, :headers => true) do |row|
  # row
  # row.each{|e| puts e}
  # or
  # do nothing, we're just timing a read...
end
faster_csv_finish_time = Time.now


csv_start_time = Time.now
require 'csv'

CSV.foreach(filename) do |row|
  # p row
  # or
  # do nothing, we're just timing a read...
end
csv_finish_time = Time.now


print 'SimpleCSV: '
puts simple_csv_file_time_delta = simple_csv_finish_time - simple_csv_start_time

print 'FasterCSV: '
puts faster_csv_time_delta = faster_csv_finish_time - faster_csv_start_time

print 'CSV: '
puts csv_time_delta = csv_finish_time - csv_start_time
