# Test CSVFile

# 20061201
# 0.4.5

out_filename = '5.csv' # Here so as I dont' forget to change it!  

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
# 4/5
# 10. Removed a lot of the commented out stuff.  
# 11. Testing writability of CSVFile.  
# 12. Changed everything from input and output to simply in and out.  
# 12. Removed the parameters from the in_file.each call.  
# 13. I'm using write_line on the out_file and the list of columns instead now.  
# 14. Switched to using CSVFile.new with the new interface for the outfile.  
# 15.  Added :double into the out_file object creation so as to tell an output file what to do with the lines!  

@debug = true
#@debug = false

require 'pp' if @debug
require '../lib/csv_file'

in_filename = 'internet_web_services.!email&website.vic.20061121.csv'

in_filename ||= Dir.glob("*.csv")[1]
out_filename ||= (
  /(.*)(\..*$)/.match(input_filename)[1] + '.to'
)

in_file = CSVFile.new(in_filename)
out_file = CSVFile.new(out_filename, true, :double, 'w')

in_file.each do |line|
  #pp line if @debug
  #if line['phone'] != ''
    out_file.write_line(line, ['name', 'address', 'phone'])
  #end
end
out_file.close
