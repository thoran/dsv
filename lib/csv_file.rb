# csv_file.rb

# 20061203 (0.4.4 - 6 incorrectly had 20061201)
# 0.4.7

# Description: A CSV file object.  

# Goals for 0.4: 
# 1. Put one or more of these interfaces onto CSVFile: 
# input_file = CSVFile.new(input_filename)
# output_file = CSVFile.new(output_filename, 'w') # Add in read/write options as the second or third parameter, before or after header_line.  
# 1. 
# input_file.each do |line|
#  output_file.write_line('name', 'address', 'phone') if line['phone'] != '' # I need to create the method #write_line.  
# end
# output_file.close
# 2. 
# output_file.write('name', 'address', 'phone')
# output_file.close
# 3. 
# output_file.each do |line|
#  line.write('name', 'address', 'phone')
# end

# Changes since 0.3: 
# 1. Changed the def to an alias for #csv_file_each.  
# 2. I thought I did this already (Maybe I forgot?)---in #each: read; @lines.each --> read.each.  Much nicer.  I'm sure I wrote this down as done before (in 0.3.7 or 8)!  
# 3. Added a conditional into #each for when one or more columns are desired.  
# 4. Changed all the scans to matches in #csv_split because a non-match returns nil and that's a little cleaner than what scan returns.  And yes, match works both ways: String.match(Regex) as well as Regex.match(String).  
# 0/1
# 5. Added   alias_method :read_line, :parse_line.  
# 6. Instead of a def I now have   alias_method :parse, :read.  
# 7. Added   alias_method :each_with_line, :each.  
# 8. Created #each_with_columns.  Incomplete as it only handles when columns are defined for now.  Copied from #each.  Time to test...  
# 1/2
# 9. Majorly mangled #each_with_columns (so as to make it work) by collecting each of the supplied parameters and yielding the resulting array.  
# 2/3
# 10. Removed #each_with_columns and (for backwards compatibility?) made it an alias for #each, whilst rolling in the bit of code with generates multiple return values.  
# 11. The only thing lost by doing this is that it is not longer possible to specify which columns are to be collected and then to have a single line parameter returned to the block.  No great loss methinks.  
# 3/4
# 12. Almost added the to_s I suspected was missing to make #each work with symbols, but realised why I didn't immediately need to do so.  
# 13. Swapped out the def for rows for an alias on lines.  
# 4/5
# 14. Finally on to the writing stuff.  Although I think the changes to each method might be of some use...  
# 15. Swapped read_line and parse_line, for no other reason than consistency.  
# 16. Added in a couple of compatibility parameters to #init which allow for setting mode and permissions on the call to this method in the File superclass.  
# 17. Created methods write, write_line, and to_csv which are all to support dumping of data to a CSV file as per Goal#1.  
# 18. Created a method #lines? to support nicer querying as to whether there is any data read from the CSV file.  
# 19. Took the debugging and reformatted #each a little.  
# 20. Added an alias #read? for #lines?.  
# 21. Added in && ['r', 'r+'].include?(mode) to the line of #initialize which sets the column names, since if a file is not open for reading, then I shouldn't be trying to read from it!  
# 22. Changed #to_csv, such that it now doesn't try to add files to the collector if that column isn't specified.  Now, by way of using columns and not @columns, whereas before I had this silly if include thing?...  
# 23. Added format/quote to the #init interface---pushing the standard file paramters yet further up the chain.  I may reorder these, but as they have defaults...?  
# 24. There's a conflict between my attempted use of File(< IO)#puts and CSVFile#write, since File#puts calls #write and an infinite loop, or till the stack is used up ensues.  It is working at the moment, but only if I don't call write, but use write_line instead (which was the case anyway) and if it is commented out!  
# 5/6
# 25. /#write/#write_csv/.  This is a temporary measure(I think?) until I can figure out to get #write to co-exist with IO#write.  
# 26. /attr_read :lines/attr_accessor :lines/ for when assigning an out file the in file's values.  This seems pretty cludgy, but we'll go with it for now.  
# 6/7
# 27. I've made a small change to CSVFile#read, whereby it rewinds as the last thing that it does before returning @lines if the mode is set to 'r+'...  Hopefully now it will over-write...  
# 28. Created @mode and read mode into it in #init!  Also changed mode to @mode in #read.  
# 29. It is simply overwriting the same number of bytes and not lines, so that means that if the number of bytes is shorter than the starting contents, that will overwrite only part of the file, so I'm going to truncate the file at the end of #read now!  
# 30. I need to do both rewind and overwrite each byte.  Well, at least I'll try this...  
# 31. Nope---probably doing something wrong.  So now, I'm trying the truncate method...  
# 32. I didn't realise that truncate doesn't have a no parameters default.  Should it?  

# Nice bits: 
# 1. In CSVFile#read, the default is to read all columns.  
# 2. In CSVFile#from_csv I couldn't decide whether to use the column name or the column position to find the required data item, so I just decided to cope with both!  
# 3. In CSVFile#column= (and #from_csv) I made it capable of accepting Array and Hash, with keys being String or Symbol.  
# 4. In CSVFile#each, it will read the file if it hasn't been read; and it doesn't need to refer to the instance variable, since the parse file is returned by the read method!  

# Todo: 
# *1. Have some means of defining constraints and raising errors as per the more custom/specific stuff in nearest.rb in class Address in the method from_csv which actually did the reading of each line part.  
# *2. Create a subclass of String called CSVLine and create the splitter method on that.  I want to try to keep this small, so I don't know if I want to go creating a class for this and a class for that...  
# 3. Default to returning something (a hash or an array) if there is no header line and if no column names are given via the columns attr_writer.  Done as of 0.0.10.  
# 4. Make #columns= be able to cope with receiving an array (as well as a hash) with the positions of the array being the the positions in the CSV file.  Done as of 0.0.7.  But I stopped playing with this about now (0.0.9).  
# *5. This is pretty inefficient as it calls #from_csv for every field desired.  Better would be for it to do this all at once.  I'll wait until I spin this off methinks.  For now just get it working OK.  
# *6. The String#csv_split stuff could be neater?...  It just got messier as of 0.0.11!  But it is slightly more accurate though...  
# *7. Switch (back?) to using symbols as the key for the column hashes.  I might wait until I spin this off before revisiting.  As far as the interface to this library/class goes, it is irrelevant.  
# *8. Have a stricter policy with respect to what formats to accept, since this is very accepting.  See Change#22 in the 0 series.  
# 9. Consider reorganising the #read loop since it is doing two branches per loop.  The option would be to have the loop in a separate method and to call it from inside each of the four options, which would be OK, so long as the loop is in the method called and is not called from the loop, since that would be more inefficient.  Done as of 0.0.14.  I've preloaded some variables to be of the same format so that there is only one conditional inside the loop now.  Extra code by way of a repeated loop might produce slightly faster times, but I won't worry about it for now.  
# *10. Take note of and then restore the current line number for when #first_line is called.  If lineno worked, perhaps?  
# *11. Write to a CSV file.  
# 12. Change String#csv_split, so as it will identify if there are no commas as well.  While this seems very unlikely for it to not find any commas at all, it is possible that what is supplied is complete crap and at least the process might halt there.  
# *13. Get the lineno method working (if possible) because while what I have done is working OK, it is a little inelegant.  
# *14. Align method names to more closely match those of File.  
# 15. Put the option to specify quoting into to_csv and possibly remove it from #init.  

# Ideas: 
# 1. Subclass CSVFile from File.  I'm not sure what this gets me, but it occurred to me that I have a read method and I was thinking of applying a close to an instance of the CSVFile class, and of course I don't have one.  Done as of 0.2.0.  
# 2. Give CSVFile an each method.  Done as of 0.3.3.  
# 3. Standardize on either symbols or strings for column names, since presently one has to be consistent.  It would be nicer to be able to mix and match---if possible.  
# 4. Have 'rw' as being a mode, since I don't get why this isn't a mode for File.  
# 5. Automatically detect as to whether there is a header line by taking the first line and comparing the types (alpha, numeric, alpha-numeric, etcetera) with each of the column values with those of the subsequent 2 or 3 or so lines and if there is a correspondence, then assume that there is a header line.  This would mean that the assumption that there is would change and that if the guess was wrong that it would need to be made explict.  
# 6. Have it #read a file automatically if any of 'r' or 'r+' or 'w+' is given as the mode.  

# Bugs: 
# 1. The CSV reading stuff doesn't strip off the quotes in each field of the CSV file.  Partially done as of 0.0.4.  See Bug#2!  
# 2. This won't as yet cope with commas within a quoted CSV file.  (Of course having quotes is pointless otherwise!)  Done as of 0.0.5.  
# 3. It doesn't strip leading or trailing quotes now!  I thought it was time to iterate, so I'll fix this in 0.0.6.  Done as of 0.0.6.  
# 4. If I input that there are no headers, don't supply any field to positional mappings and yet still want to select on the basis of a column name, it doesn't crash but gives me garbage.  
# 5. Still has a trailing comma!  Fixed as of 0.1.1.  
# 6. If I try to read a field which does not exist it crashes.  It should at least trap such an error, rather than crashing outright.  

$debug = false

require 'pp' if $debug

class String
  
  def csv_split
    pp self if $debug
    quote = :double
    double = self.match(/",|,\s"/)
    pp double if $debug
    unless double
      quote = :single
      single = self.match(/',|,\s'/) # Singly quoted CSV files are essentially unheard of, but who knows?  
      unless single
        quote = :none
        none = self.match(/,/)
        unless none
          raise RuntimeError, "This file doesn't have any commas in it.  Are you sure that this is a CSV file?"
        end # inner if
      end # middle if
    end # outer if
    result = ''
    pp quote if $debug
    case quote
      when :double
        # What follows is particularly ugly...  Anyone have a regex book handy?  
        old_result = self
	      loop do
          result = old_result.gsub(/,,/, ',"",')
		      break if result == old_result
          old_result = result
		    end
        result = result.chomp.split(/",\s*"/)
        result[0] = result[0].sub(/^"/, '')
        result[result.size - 1] = result[result.size - 1].sub(/"$/, '').sub(/",$/, '') # This last sub is more of a hack than most of the stuff here!  
      when :single
        # More ugliness ensues...
        old_result = self
	      loop do
          result = old_result.gsub(/,,/, ",'',")
		      break if result == old_result
          old_result = result
		    end
        result = self.gsub(/,,/, ",'',")
        result = result.chomp.split(/',\s*'/)
        result[0] = result[0].sub(/^'/, '')
        result[result.size - 1] = result[result.size - 1].sub(/'$/, '').sub(/',$/, '') # This last sub is also far more of a hack than most of the stuff here...  
      when :none
        result = self.chomp.split(/,\s*/)
    end # case quote
    pp result if $debug
    result
  end # def csv_split
  
end

class CSVFile < File
  
  attr_accessor :lines
  
  def initialize(filename, header_line = true, format = :double, mode = 'r', permissions = nil)
    @filename, @header_line, @quote, @mode = self.class.expand_path(filename), header_line, format, mode
    super(filename, mode, permissions)
    @columns = columns if header_line && ['r', 'r+'].include?(mode)
    @lines = []
  end
  
  def read(*desired_columns)
    number_of_columns = first_line.csv_split.size
    @header_line ? (self.rewind; self.gets) : self.rewind # Start at line 0 or line 1.  #lineno wasn't working when I first wanted this, but I will try #lineno again at some stage.  
    #pp @header_line if $debug
    case desired_columns[0]
      when Array
        if desired_columns[0] == [] # then select all columns by default...
          if @columns # then select by column name...  
            desired_columns = @columns.collect {|k, v| k}
          else # select by column position...  
            desired_columns = 0..(number_of_columns - 1)
          end
        else
          desired_columns = desired_columns[0]
        end # outer if
      else
        if desired_columns == [] # then select all columns by default...
          if @columns # then select by column name...  
            desired_columns = @columns.collect {|k, v| k}
          else # select by column position...  
            desired_columns = 0..(number_of_columns - 1)
          end
        end # outer if
    end # case
    #pp desired_columns if $debug
    self.std_file_each do |line|
      #pp line if $debug
      h = {}
      if @columns # then select by column name...  
        desired_columns.each do |column|
          h[column] = parse_line(line, column)
        end
      else # select by column position...  
        desired_columns.each do |column|
          h[column.to_i] = parse_line(line, column.to_i)
        end
      end
      @lines << h
      #pp @lines if $debug
    end
    rewind if @mode == 'r+'
    #self.each_byte {putc ''} if @mode == 'r+'
    truncate(0) if @mode == 'r+'
    @lines
  end
  alias_method :parse, :read
  
  alias_method :std_write, :write
  
  def write_csv(*columns)
    #self.puts 'blah' #debug
    #pp @lines #debug
    @lines.each do |line|
      write_line(line, columns)
    end
  end
  
  def write_line(line, columns = nil)
    #pp to_csv(line, columns) #debug
    self.puts(self.to_csv(line, columns)) # Consider creating a CSVLine class so as this line might preferably be line.to_csv.  That would mean that @lines would contain CSVLine objects, so I shouldn't forget to make other changes!  
  end
  
  def to_csv(line, columns = nil) # Consider putting *columns in later, so as to enable the supply of individual parameters as well as an array.  
    collector = []
    #pp columns #debug
    #pp line #debug
    #pp @columns #debug
    if columns
      columns.each do |c|
        collector << line[c]
      end
    else
      @columns.each do |k, v|
        collector << line[v]
      end
    end
    #pp collector #debug
    case @quote.to_sym # Also handles 'double', 'double_qoute', ...
      when :double, :double_quote, :double_quotes, :double_quoted, :doubly_quoted # No spaces, but no integrity checks.  
        return (collector[0] = '"' + collector[0]; collector[collector.size - 1] = collector[collector.size - 1] + '"'; collector.join('","'))
      when :strict_double, :strict_double_quote, :strict_double_quotes, :strict_double_quoted, :strict_doubly_quoted
        return collector.join('",')
      when :spacey_double, :spacey_double_quote, :spacey_double_quotes, :spacey_double_quoted, :spacey_doubly_quoted
        return collector.join('", ')
      when :single, :single_quote, :single_quotes, :single_quoted, :singly_quoted
        return collector.join("',")
      when :strict_single, :strict_single_quote, :strict_single_quotes, :strict_single_quoted, :strict_singly_quoted
        return collector.join("',")
      when :spacey_single, :spacey_single_quote, :spacey_single_quotes, :spacey_single_quoted, :spacey_singly_quoted
        return collector.join("', ")
      when :none, :no_quotes, :not_quoted
        return collector.join(',')
      when :strict_none, :strict_no_quote, :strict_not_quoted # I don't know what this does, since there isn't any quoting to play with, I know it simply does integrity checks...  
        return collector.join(',')
      when :spacey_none, :spacey_no_quote, :spacey_not_quoted
        return collector.join(', ')
    end # case
  end
  
  alias_method :std_each, :each
  alias_method :std_file_each, :each
  alias_method :file_each, :each
  
  def each(*columns)
    if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
      @lines.each {|line| yield line }
    else
      if columns != []
        read(columns).each {|line|
          yield columns.collect {|c| line[c] }
        }
      else
        read.each {|line| yield line }
      end
    end # outer if
  end
  alias_method :csv_file_each, :each
  alias_method :each_with_line, :each
  alias_method :each_with_columns, :each
  
  def lines?
    @lines[0]
  end
  alias_method :read?, :lines?
  
  def columns?
    @columns != nil
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
        i = -1
        column_order.each do |column|
          @columns[column.to_s] = (i += 1)
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
  
  alias_method :rows, :lines
  
  private
  
  def first_line
    self.rewind
    return_value = self.gets
    self.rewind
    return_value
  end
  
  def read_line(line, column)
    case column
      when Integer
        line.csv_split[column]
      else
        line.csv_split[@columns[column.to_s]]
    end
  end
  
  alias_method :parse_line, :read_line
  
end
