# Test CSVFile

# 20061201
# 0.3.4

# History: Derived from the csv2to tester.  

# Changes: 
# 1. Removed the require for getoptlong, since unlike csv2to, which is a command, that isn't being used here.  
# 0/1
# 2. Changed the input csv file to the second one.  
# 3. Change the output csv file to 1.csv.  
# 1/2
# 4. Changed the input file to an explicit file name, since I couldn't figure out why it wasn't working...  
# 5. Change the output csv file to 2.csv.  
# 6. Removed some debugging.  
# 2/3
# 7. Took out .lines from when iterating over a CSVFile object.  
# 3/4
# 8. Using the hash index name rather than the array index when outputting.  Why did I do it that way before at all?  

$debug = false

require 'pp' if $debug
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

output_filename = '4.csv'
input_filename = 'windscreens_&_repairs.email.vic.20061109.csv'

input_filename ||= Dir.glob("*.csv")[1]
output_filename ||= (
  input_filename.match(/(.*)(\..*$)/)[2] + '.to'
)
field_names ||= ['name', 'email']

csv_file = CSVFile.new(input_filename, true)
csv_file.read(field_names)
#csv_file.read('name', 'address')

stuff = []

#pp csv_file.lines if $debug

#csv_file.lines.each do |line|
csv_file.each do |line|
  stuff << line if line['name'] && line['email']
end

pp stuff if $debug

out_file = File.new(output_filename, 'w')
stuff.each_but_last do |line|
  out_file.print line['name'] + ", "
  out_file.print line['email'] + "\n"
end
out_file.print stuff.last['name'] + ", "
out_file.print stuff.last['email']
out_file.close
