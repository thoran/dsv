# CSVFile 0.9.2 vs. FasterCSV vs. CSV

# 2010.05.22

filename = 'cdr.csv'


simple_csv_start_time = Time.now
#require 'Kernel/require_with_rbd'
#require 'SimpleCSV'
#require 'SimpleCSV-0.9.0.rbd/SimpleCSV'
#require 'SimpleCSV-0.9.1.rbd/SimpleCSV'
require 'Kernel/require_relative'
require_relative '../../SimpleCSV-0.9.2.rbd/SimpleCSV'

# columns = [:event_id, :record_type_usage, :datetime_start, :duration_seconds, :originating_number, :terminating_number, :charged_party_number, :currency, :price_to_wholesaler, :plan_id, :distance, :is_local, :call_type, :begin_date, :end_date, :description, :number_of_items, :carrier_id, :rate_id]
# SimpleCSV.open(filename, :columns => columns) do |csv_file|
#   csv_file.each do |row|
#     p row[0]
#   end
# end
SimpleCSV.foreach(filename, :header_row => true, :quote => :none) do |row|
  # do nothing, we're just timing a read...
end
simple_csv_finish_time = Time.now


faster_csv_start_time = Time.now
require 'faster_csv'

# FasterCSV.open(filename, :headers => true) do |csv_file|
#   csv_file.each do |row|
#     p row[0]
#   end
# end
FasterCSV.foreach(filename) do |row|
  # do nothing, we're just timing a read...
end
faster_csv_finish_time = Time.now


csv_start_time = Time.now
require 'csv'

CSV.foreach(filename) do |row|
  # do nothing, we're just timing a read...
end
csv_finish_time = Time.now


print 'SimpleCSV: '
puts simple_csv_file_time_delta = simple_csv_finish_time - simple_csv_start_time

print 'FasterCSV: '
puts faster_csv_time_delta = faster_csv_finish_time - faster_csv_start_time

print 'CSV: '
puts csv_time_delta = csv_finish_time - csv_start_time
