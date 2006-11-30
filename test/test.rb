# Test CSVFile

# 20061201
# 0.3.8

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
# 4/5
# 9. Removed a lot of extraneous stuff.  
# 10. I had $debug set to false in csv_file.rb and it was over-riding it here, so I'll make this an instance variable to be different.  
# 5/6
# 11. Took out a debug line that wasn't necessary.  
# 6/7
# 7/8
# 12. Having a go at sorting...  
# 13. Not just yet, meanwhile I changed the behaviour of CSVFile#read such that it returns the lines; and so, I thought I'd use that here...  

@debug = true
#@debug = false

require 'pp' if @debug
require '../lib/csv_file'

input_filename = 'internet_web_services.!email&website.vic.20061121.csv'
output_filename = '8.csv'

input_filename ||= Dir.glob("*.csv")[1]
output_filename ||= (
  /(.*)(\..*$)/.match(input_filename)[1] + '.to'
)
pp output_filename if @debug

csv_file = CSVFile.new(input_filename)
lines = csv_file.read('name', 'address', 'phone')

pp lines if @debug
sorted_lines = lines.sort {|a, b| a['name'] <=> b['name'] }
pp sorted_lines if @debug

out_file = File.new(output_filename, 'w')
sorted_lines.each do |line|
  if line['phone'] != ''
    out_file.print line['name'] + ', '
    out_file.print line['address'] + ', '
    out_file.print line['phone'] + "\n"
  end
end
out_file.close
