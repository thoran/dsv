# Test CSVFile

# 20061201
# 0.3.1

# History: Derived from the csv2to tester.  

# Changes: 
# 1. Removed the require for getoptlong, since unlike csv2to, which is a command, that isn't being used here.  
# 0/1
# 2. Changed the input csv file to the second one.  
# 3. Change the output csv file to 1.csv.  

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

output_filename = '1.csv'

input_filename ||= Dir.glob("*.csv")[1]
output_filename ||= (
  input_filename.match(/(.*)(\..*$)/)[1] + '.to'
)
field_names ||= ['name', 'email']

csv_file = CSVFile.new(input_filename, true)
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
