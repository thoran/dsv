# benchmark/layers.rb

require 'stringio'
require_relative 'samples'

def usage
  puts "Usage: ruby benchmark/layers.rb"
  puts
  puts "Times reading the plain sample one layer of the work DSV does under :none at a time: into a Hash, as DSV gives by default, and back to an Array, as under as_array:."
end

def text
  @text ||= Samples.text(:plain)
end

def split
  rows = []
  StringIO.new(text).each("\n"){|line| rows << line.chomp("\n").split(',', -1)}
end

def through_a_lambda
  reader = ->(row){row.split(',', -1)}
  rows = []
  StringIO.new(text).each("\n"){|line| rows << reader.call(line.chomp("\n"))}
end

def to_hash(line)
  hash = {}
  i = -1
  line.chomp("\n").split(',', -1).each{|field| hash[i += 1] = field}
  hash
end

def into_a_hash
  rows = []
  StringIO.new(text).each("\n"){|line| rows << to_hash(line)}
end

def back_to_an_array
  rows = []
  StringIO.new(text).each("\n") do |line|
    hash = to_hash(line)
    rows << (0..(hash.size - 1)).inject([]){|array, i| array << hash[i]}
  end
end

def best_time(name)
  5.times.map do
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    send(name)
    Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  end.min
end

def objects_a_row(name)
  GC.start
  before = GC.stat(:total_allocated_objects)
  send(name)
  (GC.stat(:total_allocated_objects) - before).to_f / Samples::ROWS
end

def validate_args
  return if ARGV.empty?
  usage
  exit 1
end

def main
  validate_args
  [:split, :through_a_lambda, :into_a_hash, :back_to_an_array].each do |name|
    puts "%-18s %6.3f s  %5.1f objects a row" % [name, best_time(name), objects_a_row(name)]
  end
end

main
