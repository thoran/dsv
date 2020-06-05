#!/usr/bin/env ruby
# speed_including_load_times.rb

# 20111118, 19

require "minitest/autorun"

class TestSpeedIncludingLoadTimes < MiniTest::Unit::TestCase
  
  TEST_DATA_PATH = File.join(File.dirname(__FILE__), 'test_data.csv')
  
  def test_foreach_speed_with_load_times
    # require 'Kernel/require_with_rbd'
    
    start_time = Time.now
    load 'SimpleCSV.rbd/SimpleCSV.rb'
    CSVFile.foreach(TEST_DATA_PATH, :headers => true) do |row|; end
    finish_time = Time.now
    print 'SimpleCSV: '
    puts simple_csv_time_delta = finish_time - start_time
    
    load_path = `gem which fastercsv`.strip
    start_time = Time.now
    load load_path
    FasterCSV.foreach(TEST_DATA_PATH, :headers => true) do |row|; end
    finish_time = Time.now
    print 'FasterCSV: '
    puts faster_csv_time_delta = finish_time - start_time
    
    start_time = Time.now
    require 'csv'
    CSV.foreach(TEST_DATA_PATH) do |row|; end
    finish_time = Time.now
    print 'CSV: '
    puts csv_time_delta = finish_time - start_time
    
    assert(faster_csv_time_delta < csv_time_delta / 3)
    assert(simple_csv_time_delta < faster_csv_time_delta / 1.5)
  end
  
end
