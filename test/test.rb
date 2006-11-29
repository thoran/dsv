# Test CSVFile

# 20061130
# 0.0.0

# History: Derived from the csv2to tester.  

# Changes: 

require 'getoptlong'
#require 'pp'
  
require '../lib/csv_file'
  
class Array
  
  alias_method :last!, :pop
  
  def all_but_last
    d = self.dup
    d.last!
    d
  end
  
  def each_but_last
    all_but_last.each {|e| yield e }
  end
  
end

input_filename, output_filename, field_name = nil, nil, nil

opts = GetoptLong.new(
  ['--input', '--csv', '--if', '-i', GetoptLong::OPTIONAL_ARGUMENT],
  ['--output', '--to', '--of', '-o', GetoptLong::OPTIONAL_ARGUMENT],
  ['--field', '-f', GetoptLong::OPTIONAL_ARGUMENT]
  #['--verbose', GetoptLong::NO_ARGUMENT],
)
opts.each do |opt, arg|
  case opt
    when '--input', '--csv', '--if', '-i'; input_filename = arg
    when '--output', '--to', '--of', '-o'; output_filename = arg
    when '--field', '-f'; field_name = arg
    #when '--verbose'; $verbose = true      
  end
end

input_filename ||= Dir.glob("*.csv")[0]
output_filename ||= (
  input_filename.match(/(.*)(\..*$)/)[1] + '.to'
)
field_name ||= 'email'

csv_file = CSVFile.new(input_filename)

require 'pp'; pp csv_file #debug

csv_file.read(field_name)
non_empty_emails = []
csv_file.lines.each do |line|
  non_empty_emails << line if line[field_name]
end

to_file = File.new(output_filename, 'w')
non_empty_emails.each_but_last do |line|
  to_file.print line[field_name] + ','
end
to_file.print non_empty_emails.last[field_name]
to_file.close
