# csv2to

# 20061122
# 0.0.3

# Description: Take a CSV file with a column containing email addresses and grab the email addresses, outputting a comma delimted to string of those addresses.  

# Goals for 0.0: 
# 1. Have it read a CSV file.  Done as of 0.0.0.  
# 2. Have it single out the email column.  Tested as of 0.0.1, but would have worked as of 0.0.0.  

# Changes: 
# 0. I copied over the Addresses, Address, and AddressFile code from nearest.rb and put a small part of the Address#from_csv code into CSVFile#from_csv, placed the two instance variables from Addresses into CSVFile as instance variables with @list being renamed to @lines, and modified CSVFile#headers to a tiny extent so as to no longer use the Address instance variable, and then extended both CSVFile#read and CSVFile#from_csv to cope with either positional or named field selection.  
# 0/1
# 1. I added some code in the self-run section to test singling out of emails.  
# 1/2
# 2. I've changed the interface to read to accept an array as separate parameters rather than as a single parameter now.  
# 3. So as to still be able to cope with the default of selecting all columns, I've altered the case statement which checks as to whether any columns have been specified (Is columns an empty array?), since Ruby disallows *-style parameters from having defaults.  
# 2/3
# 4. Added a to_s into #from_csv, so as one can call the read method using symbols.  

# Bugs: 
# 1. The CSV reading stuff doesn't strip off the quotes in each field of the CSV file.  

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
  
  def read(*columns)
    pp columns #debug
    @header_line ? @file_handle.lineno = 1 : @file_handle.lineno = 0
    @file_handle.each do |line|
      h = {}
      case columns
        when []
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
        line.split(',')[@headers[column.to_s]].gsub(/^ /, '').chomp
    end
  end
  
end

if __FILE__ == $0
  require 'pp'
  csv_file = CSVFile.new('test.csv')
  csv_file.read('email', 'phone')
  pp csv_file.lines
  csv_file.read(:email, :phone)
  pp csv_file.lines
end
