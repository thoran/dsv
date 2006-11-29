# csv_file.rb

# 20061130
# 0.2.1

# Description: A CSV file object.  

# Discussion: 
# 1. I'm continuing the number series from csv2to 0.0.15 since while I decided to spin this off between csv2to 0.3.2 and 0.4.0, there were no changes to this part of csv2to since 0.0.15.  
# 2. All of the History, Bugs, Nice bits, and Todo's are related to this anyway.  
# 3. Interestingly, none of the testing and usage changes in csv2to during 0.1 through 0.3 required changes to this class beyond already known limitations.  
# 4. I suggest that 0.1.0 is an accurately low number in so far as how long I spent on it, but not in so far as functionality is concerned.  Because this was being developed at the time for csv2to, then it was the functionality of that which guided the version number changes.  

# Bugs: 
# 1. The CSV reading stuff doesn't strip off the quotes in each field of the CSV file.  Partially done as of 0.0.4.  See Bug#2!  
# 2. This won't as yet cope with commas within a quoted CSV file.  (Of course having quotes is pointless otherwise!)  Done as of 0.0.5.  
# 3. It doesn't strip leading or trailing quotes now!  I thought it was time to iterate, so I'll fix this in 0.0.6.  Done as of 0.0.6.  
# 4. If I input that there are no headers, don't supply any field to positional mappings and yet still want to select on the basis of a column name, it doesn't crash but gives me garbage.  
# 5. Still has a trailing comma!  Fixed as of 0.1.1.  
# 6. If I try to read a field which does not exist it crashes.  It should at least trap such an error, rather than crashing outright.  

# History: Significantly derived from the CSV reading stuff in nearest.rb.  It was overly general there, but not general enough.  This is more general.  (I just took a look at that at time of spinning this off (0.4.0) and it is so much simpler than this!  The splitter and the input options are far more comprehensive.)

# Nice bits: 
# 1. In CSVFile#read, the default is to read all columns.  
# 2. In CSVFile#from_csv I couldn't decide whether to use the column name or the column position to find the required data item, so I just decided to cope with both!  
# 3. In CSVFile#column= (and #from_csv) I made it capable of accepting Array and Hash, with keys being String or Symbol.  

# Goals for 0.2: 
# 1. See if subclassing from File works and if it works (seems aesthetically good too).  

# Changes since 0.1: 
# 1. /from_csv/parse/.  
# 2. /lines/rows/ only because I'm using the term columns and it seems to fit in with that better---although columns are the column names, not the column values.  I'm not committed to it and may change this back.  
# 3. Added < File to the CSVFile class definition.  
# 4. /@file_handle/self/.  
# 5. I decided to only use the term rows to designate parsed data and so is essentially restricted to @rows and related.  
# 6. /lines/rows/.  I changed it back again, because lines seems more natural.  Still not sure about this, but so as to accommodat rows, I'm providing a rows method which returns @lines.  
# 0/1
# 7. Do some more testing on field selection.  
# 8. /parse/parse_line/.  Being simply parse implies that it is parsing the whole file.  
# 9. Added method parse.  This could be superfluous crap, but there it is for now at least.  

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
# 1. Subclass CSVFile from File.  I'm not sure what this gets me, but it occurred to me that I have a read method and I was thinking of applying a close to an instance of the CSVFile class, and of course I don't have one.  
# 2. Give CSVFile an each method.  

class String
  
  def csv_split
    quote = :double
    result = self.chomp.split(/",\s*"/)
    if result == [self.chomp]
      quote = :single
      result = self.chomp.split(/',\s*'/) # Singly quoted CSV files are essentially unheard of, but who knows?  
      if result == [self.chomp]
        result = self.chomp.split(/,\s*/)
        if result == [self.chomp]
          raise RuntimeError, "This file doesn't have any commas in it.  Are you sure that this is a CSV file?"
        end # inner if
      end # middle if
    end # outer if
    case quote
      when :double
        result[0] = result[0].sub(/^"/, '')
        result[result.size - 1] = result[result.size - 1].sub(/"$/, '')
      when :single
        result[0] = result[0].sub(/^'/, '')
        result[result.size - 1] = result[result.size - 1].sub(/'$/, '')
    end # case quote
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
    
    if desired_columns == [] # then select all columns by default...
      if @columns # then select by column name...  
        desired_columns = @columns.collect {|k, v| k}
      else # select by column position...  
        desired_columns = 0..(number_of_columns - 1)
      end
    end
    
    self.each do |line|
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
