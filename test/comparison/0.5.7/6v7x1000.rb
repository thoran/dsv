# CSVFile 0.5.6 vs. CSVFile 0.5.7

# 20070302

class Array
  
  def sum
    self.inject{|a, e| a + e}
  end
  
end

speeds_6 = []
speeds_7 = []
debug = false
require 'pp'

1000.times do |i|
  test_6_output = `ruby test_6.rb`
  test_7_output = `ruby test_7.rb`
  test_6_speed = test_6_output.split[1]
  test_7_speed = test_7_output.split[1]
  pp test_6_speed if debug
  pp test_7_speed if debug
  speeds_6 << test_6_speed.to_f
  speeds_7 << test_7_speed.to_f
end

puts "CSVFile 0.5.6: #{speeds_6.sum/speeds_6.size}"
puts "CSVFile 0.5.7: #{speeds_7.sum/speeds_7.size}"
