# csv2to

# 20061122
# 0.0.0

# Description: Take a CSV file with a column containing email addresses and grab the email addresses, outputting a comma delimted to string of those addresses.  

# Goals for 0.0: 
# 1. Have it read a CSV file.  

# History: Significantly derived from the CSV reading stuff in nearest.rb.  It was overly general there, but not general enough.  This is more general.  I'll spin this off soon...  

# Nice bits: 
# 1. In CSVFile#read, the default is to read all columns.  
# 2. In CSVFile#from_csv I couldn't decide whether to use the column name or the column position to find the required data item, so I just decided to cope with both!  

# Todo: 
# 1. Have some means of defining constraints and raising errors as per the more custom/specific stuff in nearest.rb in class Address in the method from_csv which actually did the reading of each line part.  

class CSVFile
  
  attr_reader :lines
  
  def initialize(filename, header_line = true)
    @filename, @header_line = File.expand_path(filename), header_line
    @file_handle = File.open(@filename, 'r')
    @headers = headers if @header_line
    @lines = []
  end
  
  def read(columns = '*')
    @header_line ? @file_handle.lineno = 1 : @file_handle.lineno = 0
    @file_handle.each do |line|
      h = {}
      case columns
        when '*'
          @headers.each do |column_name, column_position|
            h[column_name] = from_csv(line, column_position)
          end
        else
          columns.each do |column|
            h[column] = from_csv(line, column)
          end
      end
      @lines << h
    end
  end
  
  def first_line
    @file_handle.rewind
    @file_handle.gets
  end
  
  def headers
    @headers ||= (
      h = {}
      i = 0
      first_line.split(',').each do |key|
        h[key.gsub(/ /, '').chomp] = i
        i += 1
      end
      h
    )
  end
  
  def from_csv(line, column)
    case column
      when Integer
        line.split(',')[column].gsub(/^ /, '').chomp
      else
        line.split(',')[@headers[column]].gsub(/^ /, '').chomp
    end
  end
  
end

if __FILE__ == $0
  require 'pp'
  csv_file = CSVFile.new('test.csv')
  csv_file.read
  pp csv_file.lines
end
