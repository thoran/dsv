#!/usr/bin/env ruby
# speed.rb

# 20111118, 19, 23

require 'Kernel/silently'
require 'minitest/autorun'
require 'minitest/benchmark'
require "timeout"
require 'rbconfig'

#require 'Kernel/require_with_rbd'
require 'SimpleCSV.rbd/SimpleCSV'
require 'faster_csv'
require 'csv'


TEST_DATA_PATH = File.join(File.dirname(__FILE__), 'test_data.csv')

class TestSpeedConstancy < MiniTest::Unit::TestCase
  
  class << self
    def bench_range
      bench_exp 1, 10_000
    end
  end
  
  def bench_SimpleCSV_read_constancy
    self.class.send(:define_method, :bench_range){bench_exp 1, 10_000}
    assert_performance_constant(0.9999) do
      CSVFile.read(TEST_DATA_PATH)
    end
  end
  
  # def bench_FasterCSV_read_constant
  #   self.class.send(:define_method, :bench_range){bench_exp 1, 10_000}
  #   assert_performance_constant (0.9999) do
  #     FasterCSV.read(TEST_DATA_PATH)
  #   end
  # end
  # 
  # def bench_CSV_read_constant
  #   self.class.send(:define_method, :bench_range){bench_exp 1, 10_000}
  #   assert_performance_constant (0.9999) do
  #     CSV.read(TEST_DATA_PATH)
  #   end
  # end
  
end

class TestSpeedLinearity < MiniTest::Unit::TestCase
  
  class << self
    def bench_range
      bench_exp 1, 100
    end
  end
  
  def bench_SimpleCSV_read_linearity
    self.class.send(:define_method, :bench_range){bench_exp 1, 10}
    assert_performance_linear(0.9999) do |n|
      n.times do
        CSVFile.read(TEST_DATA_PATH)
      end
    end
  end
  
  # def bench_FasterCSV_read_linear
  #   self.class.send(:define_method, :bench_range){bench_exp 1, 10}
  #   assert_performance_linear(0.9999) do |n|
  #     n.times do
  #       FasterCSV.read(TEST_DATA_PATH)
  #     end
  #   end
  # end
  # 
  # def bench_CSV_read_linear
  #   self.class.send(:define_method, :bench_range){bench_exp 1, 10}
  #   assert_performance_linear(0.9999) do |n|
  #     n.times do
  #       CSV.read(TEST_DATA_PATH)
  #     end
  #   end
  # end
  
end

class TestSpeedComparison < MiniTest::Unit::TestCase
  
  # BIG_DATA = "123456789\n" * 1024
  
  def csv_load_path
    File.join(Config::CONFIG['rubylibdir'], 'csv.rb')
  end
  
  def faster_csv_load_path
    `gem which fastercsv`.strip
  end
  
  def simple_csv_load_path
    'SimpleCSV.rbd/SimpleCSV.rb'
  end
  
  def load_path(library)
    case library.to_s
    when 'CSV'
      csv_load_path
    when 'FasterCSV'
      faster_csv_load_path
    when 'SimpleCSV'
      simple_csv_load_path
    end
  end
  
  def read_speed(library)
    start_time = Time.now
    100.times do
      library.read(TEST_DATA_PATH)
    end
    finish_time = Time.now
    time_delta = finish_time - start_time
    print "#{library}: "
    puts time_delta = finish_time - start_time
    time_delta
  end
  
  def test_read_speed
    puts '', 'test_read_speed'
    csv_time_delta = read_speed(CSV)
    faster_csv_time_delta = read_speed(FasterCSV)
    simple_csv_time_delta = read_speed(SimpleCSV)
    assert(faster_csv_time_delta < csv_time_delta / 3) # This is FasterCSV's own measure, not mine.  
    assert(simple_csv_time_delta < faster_csv_time_delta / 1.3)
    assert(simple_csv_time_delta < csv_time_delta / 7)
  end
  
  def read_speed_including_load_times(library)
    start_time = Time.now
    100.times do
      silently do
        load load_path(library)
      end
      library.read(TEST_DATA_PATH)
    end
    finish_time = Time.now
    time_delta = finish_time - start_time
    print "#{library}: "
    puts time_delta = finish_time - start_time
    time_delta
  end
  
  def test_read_speed_including_load_times
    puts '', 'test_read_speed_including_load_times'
    csv_time_delta = read_speed_including_load_times(CSV)
    faster_csv_time_delta = read_speed_including_load_times(FasterCSV)
    simple_csv_time_delta = read_speed_including_load_times(SimpleCSV)
    assert(faster_csv_time_delta < csv_time_delta / 3) # This is FasterCSV's own measure, not mine.  
    assert(simple_csv_time_delta < faster_csv_time_delta / 1.3)
    assert(simple_csv_time_delta < csv_time_delta / 7)
  end
  
  def foreach_speed(library)
    start_time = Time.now
    100.times do
      library.foreach(TEST_DATA_PATH){}
    end
    finish_time = Time.now
    time_delta = finish_time - start_time
    print "#{library}: "
    puts time_delta = finish_time - start_time
    time_delta
  end
  
  def test_foreach_speed
    puts '', 'test_foreach_speed'
    csv_time_delta = foreach_speed(CSV)
    faster_csv_time_delta = foreach_speed(FasterCSV)
    simple_csv_time_delta = foreach_speed(SimpleCSV)
    assert(faster_csv_time_delta < csv_time_delta / 3) # This is FasterCSV's own measure, not mine.  
    assert(simple_csv_time_delta < faster_csv_time_delta / 1.3)
    assert(simple_csv_time_delta < csv_time_delta / 7)
  end
  
  def foreach_speed_including_load_times(library)
    start_time = Time.now
    100.times do
      silently do
        load load_path(library)
      end
      library.foreach(TEST_DATA_PATH){}
    end
    finish_time = Time.now
    time_delta = finish_time - start_time
    print "#{library}: "
    puts time_delta = finish_time - start_time
    time_delta
  end
  
  def test_foreach_speed_including_load_times
    puts '', 'test_foreach_speed_including_load_times'
    csv_time_delta = foreach_speed_including_load_times(CSV)
    faster_csv_time_delta = foreach_speed_including_load_times(FasterCSV)
    simple_csv_time_delta = foreach_speed_including_load_times(SimpleCSV)
    assert(faster_csv_time_delta < csv_time_delta / 3) # This is FasterCSV's own measure, not mine.  
    assert(simple_csv_time_delta < faster_csv_time_delta / 1.3)
    assert(simple_csv_time_delta < csv_time_delta / 7)
  end
  
  def test_library_equivalence
    FasterCSV.foreach(TEST_DATA_PATH) do |faster_csv_row|
      CSV.open(TEST_DATA_PATH, 'r') do |csv_row|
        assert_equal(csv_row, faster_csv_row)
      end
    end
    
    # FasterCSV.foreach(TEST_DATA_PATH) do |csv|
    #   CSV.foreach(TEST_DATA_PATH) do |row|
    #     SimpleCSV.foreach(TEST_DATA_PATH, :header => false, :as_array => true).each do |simple_row|
    #     
    #     p csv, row
    #     assert_equal(row, csv.shift)
    #   end
    # end
    
  #   SimpleCSV.new(TEST_DATA_PATH, :header => false, :as_array => true).each do |simple_row|
  #     p simple_row
  #   end
  #   
  #   SimpleCSV.new(TEST_DATA_PATH, :header => false, :as_array => true).each do |simple_row|
  #     CSV.foreach(TEST_DATA_PATH) do |row|
  #       p row; p simple_row
  #       p 'there'
  #       assert_equal(row, simple_row)
  #     end
  #   end
  end
  
  # def test_the_parse_fails_fast_when_it_can_for_unquoted_fields
  #   assert_parse_errors_out('valid,fields,bad start"' + BIG_DATA)
  # end
  # 
  # def test_the_parse_fails_fast_when_it_can_for_unescaped_quotes
  #   assert_parse_errors_out('valid,fields,"bad start"unescaped' + BIG_DATA)
  # end
  # 
  # def test_field_size_limit_controls_lookahead
  #   assert_parse_errors_out( 'valid,fields,"' + BIG_DATA + '"',
  #                            :field_size_limit => 2048 )
  # end
  # 
  # private
  # 
  # def assert_parse_errors_out(*args)
  #   assert_raise(FasterCSV::MalformedCSVError) do
  #     Timeout.timeout(0.2) do
  #       FasterCSV.parse(*args)
  #       fail("Parse didn't error out")
  #     end
  #   end
  # end
end
