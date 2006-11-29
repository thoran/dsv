# Test CSVFile

# 20061130
# 0.0.1

# History: Derived from the csv2to tester.  

# Changes: 
# 1. Removed the command line option stuff.  
# 2. Output is line separated instead of comma separated.  
# 3. Output filename is manually set.  
# 4. Removed less debugging than this text to tell about it.  

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

output_filename = '1.txt'

input_filename ||= Dir.glob("*.csv")[0]
output_filename ||= (
  input_filename.match(/(.*)(\..*$)/)[1] + '.to'
)
field_name ||= 'name'

csv_file = CSVFile.new(input_filename)
csv_file.read(field_name)

non_empty_emails = []
csv_file.lines.each do |line|
  non_empty_emails << line if line[field_name]
end

to_file = File.new(output_filename, 'w')
non_empty_emails.each_but_last do |line|
  to_file.print line[field_name] + "\n"
end
to_file.print non_empty_emails.last[field_name]
to_file.close
