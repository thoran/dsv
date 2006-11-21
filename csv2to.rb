# csv2to

# 20061122
# 0.0.11

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
# 3/4
# 5. Changed the split parameters throughout to use a more sophisticated regex which removes any trailing spaces after a comma and consequently removed the gsubs which makes for simpler code.  
# 6. Added a gsub to the same splitter lines to cope with quoted CSV files.  It doesn't cope with commas between quotes however!  See Bugs#2.  
# 7. Added a collect to the splitter in #headers, since I'm operating on the whole array here.  
# 8. Added a variable field in to #from_csv to cope with the test for whether to apply a gsub, since some fields are empty.  
# 9. Changed the modification of a header from compressing the name by removing spaces and instead replacing spaces with underscores.  
# 4/5
# 10. Changed @headers and #headers to @columns and #columns.  
# 11. Had to change columns in #read to desired_columns to accommodate Change#10.  
# 12. Added columns as an attribute writer, so as when there isn't a header line, that same information can be programmatically 'dropped in'.  CSVFile should still be able to work even if there is no header line and no columns specified in this way.  I've added this as Todo#3.  
# 12. Created String#csv_split, so as it will solve Bug#2.  I was going to create this initially as a method in CSVFile, but wanted to stay really OO by having this message be able to be sent to strings.  See Todo#2 for (possibly) a better way.  
# 13. Swapped out the inline CSV splitting stuff in #columns and #from_csv for the new String#csv_split method.  So much cleaner!  
# 14. Added a chomp into String#csv_split, since the last element still had the linefeed attached.  
# 15. Forgot to change an instance of columns to desired_columns in #read!  Oh, so that's why!  
# 16. Removed attr_writer :columns and replaced it with def columns= so as to control the internal representation of the columns instance variable better.  This is so as to cope with being able to define column hash keys using either symbols or strings.  It will also come in handy if I make the parameter to #columns= be able to be an array somehow...  See Todo#4.  
# 5/6
# 17. Added a quote variable and a case statement to String#csv_split so as to remove Bug#3.  
# 6/7
# 18. #columns= now accepts an array, which is preferable since the column order is implicit in the order in which it is provided to the function, rather than so laboriously making it explicit with hashes.  
# 7/8
# 19. #columns= now accepts hashes again.  
# 8/9
# 20. #columns= now accepts what I really wanted and that was a simple list, which becomes an array; without any asterisks either!?...  It still accepts hashes and arrays as well.  
# 21. I changed all references to to_s to to_sym, but that wasn't working so I changed it back.  The keys as symbols, as per Todo#7 will have to wait!  
# 22. I tested putting a comma into the test.csv and it worked fine.  I haven't fully tested all the different sorts of CSV, but I'm pretty sure it will work OK.  And it is *very* tolerant of different CSV formats.  Even to the extent of each line being different!  It also will cope will with variable gaps between commas.  
# 9/10
# 23. I did that little (i += 1) trick in #columns.  Had to change the initial value to -1 though, of course.  
# 24. CSVFile now copes with unspecified column names.  I've roughly doubled the size of #read however.  It might be more efficient to do the branching elsewhere than inside the the loop there too...  
# 25. Made #first_line as idempotent as possible, insofar as it does a rewind after it grabs the first line.  Ideally it would take note of the current line number and then restore that.  I'll put that in the todo list...  
# 26. Stopped using @file_handle.lineno, since it seemed to do nothing and substituted using #rewind and gets instead.  
# 10/11
# 27.  String#cvs_split now only removes leading and trailing quotes, rather than removing all remaining quotes, and leaves alone any other quotes which are not involved in delimitation.  
# 28. Removed a bit of debugging stuff.  
# 29. Removed the columns_defined stuff from #read, since it really wasn't necessary.  

# Bugs: 
# 1. The CSV reading stuff doesn't strip off the quotes in each field of the CSV file.  Partially done as of 0.0.4.  See Bug#2!  
# 2. This won't as yet cope with commas within a quoted CSV file.  (Of course having quotes is pointless otherwise!)  Done as of 0.0.5.  
# 3. It doesn't strip leading or trailing quotes now!  I thought it was time to iterate, so I'll fix this in 0.0.6.  Done as of 0.0.6.  

# History: Significantly derived from the CSV reading stuff in nearest.rb.  It was overly general there, but not general enough.  This is more general.  I'll spin this off soon...  

# Nice bits: 
# 1. In CSVFile#read, the default is to read all columns.  
# 2. In CSVFile#from_csv I couldn't decide whether to use the column name or the column position to find the required data item, so I just decided to cope with both!  

# Todo: 
# *1. Have some means of defining constraints and raising errors as per the more custom/specific stuff in nearest.rb in class Address in the method from_csv which actually did the reading of each line part.  
# *2. Create a subclass of String called CSVLine and create the splitter method on that.  I want to try to keep this small, so I don't know if I want to go creating a class for this and a class for that...  
# 3. Default to returning something (a hash or an array) if there is no header line and if no column names are given via the columns attr_writer.  Done as of 0.0.10.  
# 4. Make #columns= be able to cope with receiving an array (as well as a hash) with the positions of the array being the the positions in the CSV file.  Done as of 0.0.7.  But I stopped playing with this about now (0.0.9).  
# *5. This is pretty inefficient as it calls #from_csv for every field desired.  Better would be for it to do this all at once.  I'll wait until I spin this off methinks.  For now just get it working OK.  
# *6. The String#csv_split stuff could be neater?...  It just got messier as of 0.0.11!  But it is slightly more accurate though...  
# *7. Switch (back?) to using symbols as the key for the column hashes.  I might wait until I spin this off before revisiting.  As far as the interface to this library/class goes, it is irrelevant.  
# *8. Have a stricter policy with respect to what formats to accept, since this is very accepting.  See Change#22 in the 0 series.  
# *9. Consider reorganising the #read loop since it is doing two branches per loop.  The option would be to have the loop in a separate method and to call it from inside each of the four options, which would be OK, so long as the loop is in the method called and is not called from the loop, since that would be more inefficient.  
# *10. Take note of and then restore the current line number for when #first_line is called.  If lineno worked, perhaps?  

class String
  
  def csv_split
    quote = :double
    result = self.chomp.split(/","\s*/)
    if result == [self.chomp]
      quote = :single
      result = self.chomp.split(/','\s*/) # Singly quoted CSV files are essentially unheard of, but who knows?  
      if result == [self.chomp]
        quote = :none
        result = self.chomp.split(/,\s*/)
      end # inner if
    end # outer if
    case quote
      when :double
        result[0] = result[0].sub(/^"/, '')
        result[result.size - 1] = result[result.size - 1].sub(/"$/, '')
        return result
      when :single
        result[0] = result[0].sub(/^'/, '')
        result[result.size - 1] = result[result.size - 1].sub(/'$/, '')
      end # case quote
      result
  end # def csv_split
  
end

class CSVFile
  
  attr_reader :lines
  
  def initialize(filename, header_line = true)
    @filename, @header_line = File.expand_path(filename), header_line
    @file_handle = File.open(@filename, 'r')
    @columns = columns if @header_line
    @lines = []
  end
  
  def read(*desired_columns)
    columns_size = first_line.csv_split.size
    if @header_line then @file_handle.rewind; @file_handle.gets else @file_handle.rewind end
    @file_handle.each do |line|
      h = {}
      if @columns # Am I selecting by column name?
        case desired_columns
          when [] # Select all columns by default.  
            @columns.each do |column_name, column_position|
              h[column_name] = from_csv(line, column_position)
            end
          else
            desired_columns.each do |column|
              h[column] = from_csv(line, column)
            end
        end
      else # Select by column position.  Further I'll assume that there is no header line.  
        case desired_columns
          when [] # Select all columns by default.  
            0.upto(columns_size - 1) do |column_position|
              h[column_position] = from_csv(line, column_position)
            end
          else
            desired_columns.each do |column|
              h[column.to_i] = from_csv(line, column.to_i)
            end
        end
      end
      @lines << h
    end
  end
  
  def columns=(column_order)
    case column_order
      when Hash
        @columns = {}
        column_order.each do |column_name, column_position|
          @columns[column_name.to_s] = column_position
        end
      when Array
        @columns = {}
        i = 0
        column_order.each do |column|
          @columns[column.to_s] = i
          i += 1
        end
    end # case column_order
  end
  
  def columns
    @columns ||= (
      h = {}
      i = -1
      first_line.csv_split.each do |key|
        h[key.gsub(/ /, '_').chomp] = (i += 1)
      end
      h
    )
  end
  
  private
  
  def first_line
    @file_handle.rewind
    return_value = @file_handle.gets
    @file_handle.rewind
    return_value
end
  
  def from_csv(line, column)
    case column
      when Integer
        line.csv_split[column]
      else
        line.csv_split[@columns[column.to_s]]
    end
  end
  
end

if __FILE__ == $0
  require 'pp'
  
  csv_file = CSVFile.new('test.csv')
  csv_file.read
  pp csv_file.lines
  
  csv_file = CSVFile.new('test.csv', false)
  csv_file.read
  pp csv_file.lines
  
end
