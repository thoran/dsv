# Test CSVFile

# 20061130
# 0.0.2

# History: Derived from the csv2to tester.  

# Changes: 
# 1. Removed the command line option stuff.  
# 2. Output is line separated instead of comma separated.  
# 3. Output filename is manually set.  
# 4. Removed less debugging than this text to tell about it.  
# 1/2
# 5. Added an array input for the file names so as to test multiples and how it would handle explicit arrays.  Badly as it turned out and as I thought it would.  
# 6. Various other output changes to cope with multiple values per line.  Not very extensible at all.  I need CSVFile.write!  

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

output_filename = '2.txt'

input_filename ||= Dir.glob("*.csv")[0]
output_filename ||= (
  input_filename.match(/(.*)(\..*$)/)[1] + '.to'
)
field_names ||= ['name', 'address']

csv_file = CSVFile.new(input_filename)
csv_file.read(field_names)
#csv_file.read('name', 'address')

stuff = []
csv_file.lines.each do |line|
  stuff << line if line[field_names[0]] && line[field_names[1]]
end

require 'pp'; pp stuff #debug

out_file = File.new(output_filename, 'w')
stuff.each_but_last do |line|
  out_file.print line[field_names[0]] + ", "
  out_file.print line[field_names[1]] + "\n"
end
out_file.print stuff.last[field_names[0]] + ", "
out_file.print stuff.last[field_names[1]]
out_file.close
