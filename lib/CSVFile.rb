# CSVFile.rb

# 20090105
# 0.6.2

# Description: A CSV file object.  

# Goals for 0.6: 
# 1. Have it be able to read mixed CSV files.  
# 2. Have it be able to read escaped and quoted delimeters.  
# 3. Be able to use the standard File method names.  
# 4. Remove any unnecessary code.  
# 5. One or two of the Todo's...  
# 6. Fix the remaining bugs...  
# 7. Create a foreach method.  
# 8. Separate out the different classes into separate files.  
# 9. Create a gem.  
# 10. Rubylibify.  

# Changes since 0.5: 
# 1. Added in File/IO similarity/compatibility stuff.  
# 2. Added the capacity for mixed quotations on a line.  (Yet to be tested thoroughly.)  
# 3. String was extended with a raft of new methods.  
# 4. Array was extended with a couple of methods.  (With one being unnecessary probably.)  
# 0/1
# 2. Split the standard ruby library extensions into own files.  
# 3. Added a separator option in all interfaces, as is consistent with File/IO, even if it probably doesn't get used.  (Maybe piss it off too?...)  
# 4. CSVFile#headers, aliased from CSVFile#attributes.  
# 5. Corrected some errors in the class methods.  
# 1/2
# 6. 

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
# 5. This is pretty inefficient as it calls #from_csv for every field desired.  Better would be for it to do this all at once.  I'll wait until I spin this off methinks.  For now just get it working OK.  Started some time ago, but properly working as of 0.5.3.  
# *6. The String#csv_split stuff could be neater?...  It just got messier as of 0.0.11!  But it is slightly more accurate though...  
# *7. Switch (back?) to using symbols as the key for the column hashes.  I might wait until I spin this off before revisiting.  As far as the interface to this library/class goes, it is irrelevant.  
# *8. Have a stricter policy with respect to what formats to accept, since this is very accepting.  See Change#22 in the 0 series.  
# 9. Consider reorganising the #read loop since it is doing two branches per loop.  The option would be to have the loop in a separate method and to call it from inside each of the four options, which would be OK, so long as the loop is in the method called and is not called from the loop, since that would be more inefficient.  Done as of 0.0.14.  I've preloaded some variables to be of the same format so that there is only one conditional inside the loop now.  Extra code by way of a repeated loop might produce slightly faster times, but I won't worry about it for now.  
# *10. Take note of and then restore the current line number for when #first_line is called.  If lineno worked, perhaps?  
# 11. Write to a CSV file.  Initially done as of 0.4.5.  
# 12. Change String#csv_split, so as it will identify if there are no commas as well.  While this seems very unlikely for it to not find any commas at all, it is possible that what is supplied is complete crap and at least the process might halt there.  It does this as of long time back...  0.1.1!  However, what of when there is only one column of data?  Either I need the ability to go to 'manual' or I take this out.  
# *13. Get the lineno method working (if possible) because while what I have done is working OK, it is a little inelegant.  
# *14. Align method names to more closely match those of File.  
# *15. Put the option to specify quoting into to_csv and possibly remove it from #init.  
# *16. When strict is specified, do some checks for column count consistency, and possibly re-apply checks for data consistency as per the idea (Did I write this idea down?) to attempt to automatically detect if there is a header line by comparing the data of the first line with subsequent lines (by way of column length, type, and anything else I can figure to use).  So, I'd need to write that in a sufficiently general way to be used in both contexts.  
# 17. Remove underscores when outputting the header line, but only if they were added---and only if they're wanting to be removed?...  
# *18. Reorder the conditionals in #write_line and #write_header.  

# Ideas: 
# 1. Subclass CSVFile from File.  I'm not sure what this gets me, but it occurred to me that I have a read method and I was thinking of applying a close to an instance of the CSVFile class, and of course I don't have one.  Done as of 0.2.0.  As of 0.4.9, this is still not quite working right---particularly the write method clash, so started 0.2.0 might be a better way to put it.  
# 2. Give CSVFile an each method.  Done as of 0.3.3.  
# 3. Standardize on either symbols or strings for column names, since presently one has to be consistent.  It would be nicer to be able to mix and match---if possible.  
# 4. Have 'rw' as being a mode, since I don't get why this isn't a mode for File.  
# 5. Automatically detect as to whether there is a header line by taking the first line and comparing the types (alpha, numeric, alpha-numeric, etcetera) with each of the column values with those of the subsequent 2 or 3 or so lines and if there is a correspondence, then assume that there is a header line.  This would mean that the assumption that there is would change and that if the guess was wrong that it would need to be made explict.  
# 6. Have it #read a file automatically if any of 'r' or 'r+' or 'w+' is given as the mode.  

# Bugs: 
# 1. The CSV reading stuff doesn't strip off the quotes in each field of the CSV file.  Partially done as of 0.0.4.  See Bug#2!  That would mean that it was fixed in 0.0.5?  
# 2. This won't as yet cope with commas within a quoted CSV file.  (Of course having quotes is pointless otherwise!)  Done as of 0.0.5.  
# 3. It doesn't strip leading or trailing quotes now!  I thought it was time to iterate, so I'll fix this in 0.0.6.  Done as of 0.0.6.  
# 4. If I input that there are no headers, don't supply any field to positional mappings and yet still want to select on the basis of a column name, it doesn't crash but gives me garbage.  
# 5. Still has a trailing comma!  Fixed as of 0.1.1.  
# 6. If I try to read a field which does not exist it crashes.  It should at least trap such an error, rather than crashing outright.  
# 7. Header lines are not being written out either as the default, nor even if such is specified.  Fixed as of 0.5.4.  

$debug = {}
$debug[:String_csv_split] = false
$debug[:Array_wrap_each] = false
$debug[:Array_to_csv] = false
$debug[:read] = false
$debug[:write_csv] = false
$debug[:write_header] = false
$debug[:write_line] = false
$debug[:each] = false
$debug[:first_line] = false
require 'pp' if (b = false; $debug.each{|method, debug| b = true if debug}; b)

$profile = false
require 'profile' if $profile

require File.expand_path(File.dirname(__FILE__) + '/String')
require File.expand_path(File.dirname(__FILE__) + '/Array')
require File.expand_path(File.dirname(__FILE__) + '/Hash')

class CSVFile < File
  
  attr_accessor :lines, :header_line, :quote
  alias_method :rows, :lines
  
  def initialize(filename, mode = 'r', permissions = nil)
    @header_line = true
    @quote = :double
    @filename = self.class.expand_path(filename)
    @mode = mode
    @permissions = permissions
    unless @header_line.class == TrueClass || @header_line.class == FalseClass
      case @header_line.to_sym
        when :header_line, :header, :heading
          @header_line = true
        when :no_header_line, :no_header, :no_heading
          @header_line = false
        else # unrecognised attempt at specifying a header line, so just assume so anyway.  Let any errors be caught as they may further on...  
          @header_line = true
      end # case @header_line
    end # unless
    case @mode.to_s # It can handle :read, :write, ...
      when 'r', 'r+', 'w', 'w+', 'a', 'a+'
      when 'read', 'read_only', 'readonly'
        @mode = 'r'
      when 'rw', 'read_write', 'readwrite', 'read_plus', 'read+', 'readplus', 'read_+'
        @mode = 'r+'
      when 'write', 'w_only', 'write_only', 'writeonly'
        @mode = 'w'
      when 'wr', 'write_read', 'writeread', 'write_plus', 'write+', 'writeplus', 'write_+', 'w_plus', 'wplus', 'w_+'
        @mode = 'w+'
      when 'append', 'w_append', 'write_append', 'w_only_append', 'write_only_append', 'writeonly_append'
        @mode = 'a'
      when 'rw_append', 'read_write_append', 'readwrite_append', 'read_plus_append', 'read+_append', 'readplus_append', 'read_+_append', 'r+_append', 'r_+_append'
        @mode = 'a+'
      else # unrecognised attempt at specifying a mode, so just make it read.  Let any errors be caught as they may further on...  
        @mode = 'r'
    end # case @mode.to_s
    super(@filename, @mode, permissions)
    @columns = columns if header_line && ['r', 'r+', 'a+'].include?(@mode)
    #@attributes = attributes if header_line && ['r', 'r+', 'a+'].include?(@mode)
    @lines = []
  end
  
  class << self
    attr_accessor :header_line
    
    def open(filename, mode = 'r', permissions = nil)
      csv_file = new(filename, mode, permissions)
      if block_given?
        begin
          yield csv_file
        ensure
          csv_file.close
        end
      else
        csv_file
      end
    end
    
    def each(filename, separator = "\n", &block)
      open(filename) do |csv_file|
        csv_file.each(separator, &block)
      end
    end
    alias_method :foreach, :each
    
    def readlines(filename, separator = "\n", *desired_columns)
      csv_file = new(filename)
      csv_file.read_csv(separator, *desired_columns)
    end
    alias_method :read_lines, :readlines
    
    def read(filename, *desired_columns)
      readlines(filename, *desired_columns)
    end
    alias_method :read_csv, :read
    
    def writelines(filename, *desired_columns)
      csv_file = new(filename, true, :double, 'w')
      csv_file.write_csv(*desired_columns)
    end
    alias_method :write_lines, :writelines
    
    def write(filename, *desired_columns)
      writelines(filename, *desired_columns)
    end
    alias_method :write_csv, :write
    
  end # class << self
  
  def read_csv(separator = "\n", *columns)
    number_of_columns = first_line(separator).csv_split.size
    @header_line ? (rewind; gets) : rewind # Start at line 0 or line 1.  #lineno wasn't working when I first wanted this, but I will try #lineno again at some stage.  
    case columns[0]
      when Array
        if columns[0] == [] # then select all columns by default...
          if @columns # then select by column name...  
            columns = @columns.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]}
          else # select by column position...  
            columns = 0..(number_of_columns - 1)
          end
        else
          columns = columns[0] # I could check that what is provided really is a column, for when @columns exists by having an additional if here.  
        end # outer if
      else # the first item is (and presumably subsequent items are) somewhat more atomic...
        if columns == [] # then select all columns by default...
          if @columns # then select by column name...  
            columns = @columns.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]}
          else # select by column position...  
            columns = 0..(number_of_columns - 1)
          end
        else
          columns = columns # Redundant, but so as to be explicit.  
        end # outer if
    end # case
    pp columns if $debug[:read]
    file_each(separator) do |line|
      h = {}
      if @columns # then select by column name...  
        i = -1
        parse_line(line).each{|column| h[columns[@columns[columns[(i += 1)]]]] = column}
      else # select by column position...  
        i = -1
        parse_line(line).each{|column| h[(i += 1)] = column}
      end
      @lines << h
      pp @lines if $debug[:read]
    end # file_each
    (rewind; truncate(0)) if @mode == 'r+'
    @lines
  end # def read
  alias_method :parse, :read_csv
  alias_method :parse_csv, :read_csv
  
  def read_line(line, column = nil)
    if column
      case column
        when Integer
          line.csv_split(@quote)[column]
        else
          line.csv_split(@quote)[@columns[column.to_s]]
      end
    else
      line.csv_split(@quote)
    end
  end
  alias_method :parse_line, :read_line
  alias_method :readln, :read_line
  alias_method :readline, :read_line
  
  #alias_method :std_write, :write
  
  def write_csv(*columns)
    pp columns, @header_line if $debug[:write_csv]
    write_header(*columns) if @header_line
    each{|line| write_line(line, *columns)}
  end
  
  def write_header(*columns)
    pp columns, @header_line if $debug[:write_header]
    case columns[0]
      when Array
        columns[0] != [] ? write_line(columns[0].to_csv) : write_line(attributes.to_csv)
      else
        columns != [] ? write_line(columns.to_csv) : write_line(attributes.to_csv)
    end # case columns
  end # def write_header
  
  def write_line(line, *columns)
    pp line, columns, @columns if $debug[:write_line]
    collector = []
    #pp columns[0] if $debug[:write_line]
    case columns[0]
      when Array
        pp 'case columns[0]; when Array' if $debug[:write_line]
        columns[0] != [] ?
          columns[0].each {|c| collector << line[c] unless line[c].nil?} :
          attributes.each {|column| collector << line[column] unless line[column].nil?}
      else
        pp 'case columns[0]... else' if $debug[:write_line]
        columns != [] ?
          columns.each {|c| collector << line[c] unless line[c].nil?} :
          attributes.each {|column| collector << line[column] unless line[column].nil?}
    end # case
    pp collector if $debug[:write_line]
    puts(collector.to_csv(@quote))
  end # def write_line
  alias_method :writeln, :write_line
  alias_method :writeline, :write_line
  alias_method :write_row, :write_line
  alias_method :writerow, :write_line
  
  alias_method :std_each, :each
  alias_method :std_file_each, :each
  alias_method :file_each, :each
  
  def each(separator = "\n", *columns)
    pp columns if $debug[:each]
    if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
      @lines.each{|line| yield line}
    else # nothing has been read yet...
      if columns != [] # then 
        read_csv(separator, columns).each do |line|
          yield columns.collect{|c| line[c]}
        end
      else
        read_csv(separator).each{|line| yield line}
      end
    end # outer if
  end
  alias_method :csv_file_each, :each
  alias_method :each_with_line, :each
  
  def each_with_columns(separator = "\n", *desired_columns)
    case desired_columns[0]
      when Array
        if desired_columns[0]
          if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
            @lines.each {|line|
              yield desired_columns[0].collect {|c| line[c]}
            }
          else
            read_csv(separator, desired_columns[0]).each {|line|
              yield desired_columns[0].collect {|c| line[c]}
            }
          end # inner if
        else
          read_csv.each {|line|
            yield attributes.collect {|a| line[a]} # I assume that I need to use attributes here too.  
          }
        end # outer if
      else
        if desired_columns != []
          if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
            @lines.each {|line|
              yield desired_columns.collect {|c| line[c]}
            }
          else
            read_csv(desired_columns).each {|line|
              yield desired_columns.collect {|c| line[c]}
            }
          end # inner if
        else
          read_csv.each {|line|
            #yield @columns.collect {|k,v| line[k]} # I really do not understand why this doesn't work.  I'm leaving this here because it is so annoying that I don't get how it works.  
            yield attributes.collect {|a| line[a]}
          }
        end # outer if
    end # case
  end
  
  def columns(separator = "\n")
    pp '#columns' if $debug[:columns]
    @columns ||= (
      if @header_line  
        h = {}
        i = -1
        first_line(separator).csv_split.each do |key|
          h[key.gsub(/ /, '_').chomp.to_sym] = (i += 1) # I may remove the underscore substitution, but then symbols are in a bit of strife...
        end
        h
      else
        nil
      end
    )
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
  
  def columns?
    @columns != nil
  end
  
  def attributes
    @attributes ||= (
      columns ? columns.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]} : nil
    )
  end
  alias_method :headers, :attributes
  
  private
  
  def first_line(separator = "\n")
    pp self if $debug[:first_line]
    self.rewind
    return_value = self.gets(separator)
    self.rewind
    pp return_value if $debug[:first_line]
    return_value
  end
  
  def lines?
    @lines[0]
  end
  alias_method :read?, :lines?
  
end # class CSVFile
