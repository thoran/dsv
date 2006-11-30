# csv_file.rb

# 20061201
# 0.3.8

# Description: A CSV file object.  

# Goals for 0.3: 
# 1. At the very least, fix the parsing bug, which causes something like "item_1","item_2",,"item_4" to fail.  Done as of 0.4.0, but it didn't work entirely correctly until 0.4.1 because while it handled sequences in between OK, it still stuffed up with trailing commas until 0.4.1.  
# 2. OK, I can't justify a whole minor revision just to fix #csv_split so um, how about doing Idea#2?  Alright then, I shall implement an iterator.  So that rather than calling this object with csv_file.lines.each, it is called with csv_file.each.  Done as of 0.3.3.  

# Changes since 0.2: 
# 1. Modified String#csv_split to cope with two or more commas together (when there is no data in that column or columns) by /result/test_split/ and then applying a gsub to the string/self prior to reapplying the same split as for test_split.  Otherwise I could leave it as is!  
# 2. Forgot to cope with the fact that result is no longer being generated at the start of csv_split and so when a file has non-quoted columns, then there's nothing there.  I knew that I'd need the quote = :none line again!  
# 0/1
# 3. It doesn't deal with trailing commas (when the last column, but not last columns I think; only the last column) and inserts that and the last quote into the output...  Either I will simply truncate both end quotes and end quotes and trailing commas, or I'll remove them prior to doing the tidy-up of the first and last columns.  
# 4. So, for now I've tacked on some more subs in #csv_split.  
# 5. Oh right.  So, windscreens_&_repairs.email.vic.20061109.csv wasn't the first csv file anymore because I what?  Oh yeah, output 0.csv...  Modified 1.rb test runner accordingly.  
# 1/2
# 6. Removed all the debugging output.  
# 2/3
# 7. Created #each.  
# 8. It's stuffing up for some reason, so I've created $debug and turned all of what was or was going to be #debug into 'if $debug'.  
# 3/4
# 9. Turned off debugging.  
# 4/5
# 10. More testing with other files.  I've found that String#csv_split screws up when a line has nothing but gaps in the columns, like ",,"...",," and never has "," anywhere.  
# 5/6
# 11. Significantly re-did String#csv_split.  
# 6/7
# 12. Finished the changes required in #csv_split.  I really need to change this stuff though.  
# 13. In #csv_split changed the value of old_result to simply self.  It was an aesthetics thing, even though it might have been marginally quicker leaving it as it was.  
# 14. Changed #csv_split again to accommodate the edge case where the line has nothing but commas until the last column.  The scans for quotes would fail under such circumstances as it was.  
# 7/8
# 15. #read now returns @lines.  
# 16. Added a couple more aliases for File#each.  
# 17. Made CSVFile#each smarter, such that it will now attempt to read the file if it hasn't been read yet.  It only does a default read presently and doesn't take desired columns, which would need to be fed into the each method first.  (I had this in mind, but was waiting for a later version.  It just started to happen!  I was thinking a few hours ago that it would be really sweet to be able to do something like csv_file.each('name', 'address', 'phone') do |name, address, phone|...  I would still want to retain it returning lines however, so I'd have to make sure that by entering parameters it defaulted to returning lines and returning only one value in the yield.  I don't know why Matz doesn't like that stuff!  
# 18. I just realised that I could rewrite #each such that I can dispense with the @lines: /read; @lines.each do/read.each do/, since read now returns @lines!  Nice.  
# 19. Created #csv_file_each to accompany #file_each.  

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
# 14. Align method names to more closely match those of File.  

# Ideas: 
# 1. Subclass CSVFile from File.  I'm not sure what this gets me, but it occurred to me that I have a read method and I was thinking of applying a close to an instance of the CSVFile class, and of course I don't have one.  Done as of 0.2.0.  
# 2. Give CSVFile an each method.  Done as of 0.3.3.  

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
    double = self.scan(/",|,\s"/)
    pp double if $debug
    unless double[0]
      quote = :single
      single = self.scan(/',|,\s'/) # Singly quoted CSV files are essentially unheard of, but who knows?  
      unless single[0]
        quote = :none
        none = self.scan(/,/)
        unless none[0]
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
  
  attr_reader :lines
  
  def initialize(filename, header_line = true)
    @filename, @header_line = self.class.expand_path(filename), header_line
    super(filename)
    @columns = columns if header_line
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
    @lines
  end
  
  alias_method :std_each, :each
  alias_method :std_file_each, :each
  alias_method :file_each, :each
  
  def each
    if @lines[0]
      @lines.each {|line| yield line }
    else
      read; @lines.each {|line| yield line }
    end
  end
  
  def csv_file_each
    each
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
  
  def rows
    @lines
  end
  
  def parse(*desired_columns)
    read(desired_columns)
  end
  
  private
  
  def first_line
    self.rewind
    return_value = self.gets
    self.rewind
    return_value
  end
  
  def parse_line(line, column)
    case column
      when Integer
        line.csv_split[column]
      else
        line.csv_split[@columns[column.to_s]]
    end
  end
  
end
