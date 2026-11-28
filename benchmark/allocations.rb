# benchmark/allocations.rb

require 'objspace'
require 'stringio'
require_relative 'samples'

ROWS = 1_000

def usage
  puts "Usage: ruby benchmark/allocations.rb [--as-array] LIB_DIRECTORY [quoted|mixed|plain] [QUOTE_MODE]"
  puts
  puts "Lists the lines in LIB_DIRECTORY which make objects while the DSV there reads #{ROWS} rows of the sample, quoted by default, into Hashes, or into Arrays under --as-array."
end

def args
  @args ||= ARGV - ['--as-array']
end

def as_array?
  ARGV.include?('--as-array')
end

def validate_args
  return if (1..3).include?(args.length) && Samples::FIELDS.key?(kind)
  usage
  exit 1
end

def lib_directory
  @lib_directory ||= File.expand_path(args[0])
end

def kind
  (args[1] || 'quoted').to_sym
end

def dsv
  options = {}
  options[:quote] = args[2].to_sym if args[2]
  options[:as_array] = true if as_array?
  DSV.new(StringIO.new(Samples.text(kind, ROWS)), **options)
end

def site(object)
  file = ObjectSpace.allocation_sourcefile(object)
  return unless file&.start_with?(lib_directory)
  "#{file.delete_prefix(lib_directory + '/')}:#{ObjectSpace.allocation_sourceline(object)} #{object.class}"
end

def count_sites(counts)
  ObjectSpace.each_object do |object|
    where = site(object)
    counts[where] += 1 if where
  end
end

def allocations
  counts = Hash.new(0)
  reader = dsv
  GC.disable
  ObjectSpace.trace_object_allocations do
    before = GC.stat(:total_allocated_objects)
    reader.read
    counts[:total] = GC.stat(:total_allocated_objects) - before
    count_sites(counts)
  end
  counts
ensure
  GC.enable
end

def report(counts)
  puts "%6.2f  objects a row in all" % [counts.delete(:total).to_f / ROWS]
  counts.sort_by{|_, count| -count}.each{|where, count| puts "%6.2f  %s" % [count.to_f / ROWS, where]}
end

def main
  validate_args
  $LOAD_PATH.unshift(lib_directory)
  require 'dsv'
  report(allocations)
end

main
