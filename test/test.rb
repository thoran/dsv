# Test CSVFile

# 20061201
# 0.4.1

# Changes since 0.3: 
# 1. Commented out the sorting stuff.  
# 2. Added in a direct reference to the csv_file for the iterator using the new interface on #each.  
# 0/1
# 3. Swapped to using #each_with_columns.  

@debug = true
#@debug = false

require 'pp' if @debug
require '../lib/csv_file'

input_filename = 'internet_web_services.!email&website.vic.20061121.csv'
output_filename = '1.csv'

input_filename ||= Dir.glob("*.csv")[1]
output_filename ||= (
  /(.*)(\..*$)/.match(input_filename)[1] + '.to'
)
#pp output_filename if @debug

csv_file = CSVFile.new(input_filename)
#lines = csv_file.read('name', 'address', 'phone')

#pp lines if @debug
#sorted_lines = lines.sort {|a, b| a['name'] <=> b['name'] }
#pp sorted_lines if @debug

out_file = File.new(output_filename, 'w')

csv_file.each_with_columns('name', 'address', 'phone') do |name, address, phone|
  if line['phone'] != ''
    out_file.print name + ', '
    out_file.print address + ', '
    out_file.print phone + "\n"
  end
end
out_file.close
