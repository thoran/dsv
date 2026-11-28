# benchmark/read_and_write.rb

require 'stringio'
require_relative 'samples'

def usage
  puts "Usage: ruby benchmark/read_and_write.rb csv|LIB_DIRECTORY [FILES_DIRECTORY]"
  puts
  puts "Times reading and writing by stdlib CSV, or by the DSV in LIB_DIRECTORY, as the best of 5 runs, with the objects made a row."
  puts "DSV reads each into Hashes, as it does by default, and into Arrays, under as_array:; stdlib CSV reads into Arrays."
  puts "Each of the files in FILES_DIRECTORY is read, and written back, beside the samples."
  puts "Run it once for each reader, so as each is timed in a process of its own."
end

def validate_args
  return if (1..2).include?(ARGV.length)
  usage
  exit 1
end

def csv?
  ARGV[0] == 'csv'
end

def load_reader
  if csv?
    require 'csv'
  else
    $LOAD_PATH.unshift(File.expand_path(ARGV[0]))
    require 'dsv'
  end
end

def label
  csv? ? "csv #{CSV::VERSION}" : "dsv #{DSV::VERSION}"
end

def files
  @files ||= Dir[File.join(ARGV[1], '*')].sort.map{|path| File.read(path)}
end

def read_cases
  cases = []
  cases << ['the files, default', files, nil] unless ARGV[1].nil?
  cases += [
    ['quoted, default', [Samples.text(:quoted)], nil],
    ['quoted, :double', [Samples.text(:quoted)], :double],
    ['mixed, default', [Samples.text(:mixed)], nil],
    ['plain, default', [Samples.text(:plain)], nil],
    ['plain, :none', [Samples.text(:plain)], :none],
  ]
  csv? ? cases.reject{|_, _, quote| quote} : cases
end

def shapes
  csv? ? ['arrays'] : ['hashes', 'arrays']
end

def dsv_options(quote, shape)
  options = {}
  options[:quote] = quote if quote
  options[:as_array] = true if shape == 'arrays'
  options
end

def read(text, quote, shape)
  if csv?
    CSV.parse(text)
  else
    DSV.new(StringIO.new(text), **dsv_options(quote, shape)).read
  end
end

def write_name
  "#{ARGV[1] ? 'the files' : 'mixed'}, #{csv? ? 'arrays' : 'hashes'}"
end

def texts_to_write
  ARGV[1] ? files : [Samples.text(:mixed)]
end

def rows_to_write
  @rows_to_write ||= texts_to_write.map{|text| csv? ? CSV.parse(text) : DSV.new(StringIO.new(text)).read}
end

def write(rows)
  if csv?
    CSV.generate(+''){|out| rows.each{|row| out << row}}
  else
    dsv = DSV.new(StringIO.new(+''), mode: 'w')
    rows.each{|row| dsv.write_row(row)}
  end
end

def best_time
  5.times.map do
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
  end.min
end

def objects_a_row(rows)
  GC.start
  before = GC.stat(:total_allocated_objects)
  yield
  (GC.stat(:total_allocated_objects) - before).to_f / rows
end

def report(action, name, rows, &block)
  puts "%-12s %-6s %-30s %6.3f s  %5.1f objects a row" % [label, action, name, best_time(&block), objects_a_row(rows, &block)]
end

def read_all
  read_cases.each do |name, texts, quote|
    rows = texts.sum{|text| text.count("\n")}
    shapes.each{|shape| report('read', "#{name}, #{shape}", rows){texts.each{|text| read(text, quote, shape)}}}
  end
end

def write_all
  report('write', write_name, rows_to_write.sum(&:size)){rows_to_write.each{|rows| write(rows)}}
end

def main
  validate_args
  load_reader
  read_all
  write_all
end

main
