# Test CSVFile

# 20061201
# 0.4.4

output_filename = '4.csv' # Here so as I don't forget to change this!  

# Changes since 0.3: 
# 1. Commented out the sorting stuff.  
# 2. Added in a direct reference to the csv_file for the iterator using the new interface on #each.  
# 0/1
# 3. Swapped to using #each_with_columns.  
# 1/2
# 4. Fixed a reference to line which shouldn't have been there.  
# 5. Now using the new on-the-fly block parameters for CSVFile's new method #each_with_columns.  
# 2/3
# 6. Moved output_filename up near the version number for reasons as best stated there.  
# 3/4
# 7. Checked to see if #read would handle symbols and it does by virtue of a column.to_s in #parse_line.  
# 8. Now checking to see if #each will handle symbols (I think it won't and I think I know why...)  And it did!  
# 9.  However, one has to be consistent.  I can't mix'n'match strings and symbols.  

@debug = true
#@debug = false

require 'pp' if @debug
require '../lib/csv_file'

input_filename = 'internet_web_services.!email&website.vic.20061121.csv'


input_filename ||= Dir.glob("*.csv")[1]
output_filename ||= (
  /(.*)(\..*$)/.match(input_filename)[1] + '.to'
)
#pp output_filename if @debug

csv_file = CSVFile.new(input_filename)
#lines = csv_file.read(:name, :address, :phone)

#pp lines if @debug
#exit if @debug

#sorted_lines = lines.sort {|a, b| a['name'] <=> b['name'] }
#pp sorted_lines if @debug

out_file = File.new(output_filename, 'w')

csv_file.each(:name, :address, :phone) do |name, address, phone|
  if phone != ''
    out_file.print name + ', '
    out_file.print address + ', '
    out_file.print phone + "\n"
  end
end
out_file.close
