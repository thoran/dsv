# csv_file.rb

# 20061205
# 0.5.2

# Description: A CSV file object.  

# Goals for 0.5: 
# 1. I suppose a bit of refactoring.  
# 2. 

# Changes since 0.4: 
# 1. Rearranged things a little.  Put read_line next to read, etcetera.  
# 2. Added some aliases for :write_csv and some for :read_line.  
# 3. Modified #read_line, such that if the column isn't specified that it will return the whole line parsed into an array.  
# 4. I've optimised #read such that if no columns are specified then it will read the whole line in a go, rather than one column at a time.  I can optimise this further and simplify it by calling parse_line once only for all circumstances.  
# 5. Removed the when Array bizzo from #write_csv, since I'm simply passing that into #write_line anyway, so I thought I'd let it handle it by passing it through as found, and so added * to columns and removed the remainder.  
# 6. Aliased #write_csv to #csv_write.  I think I prefer this and may swap, but which I'll be consistent and do the same with #csv_split.  
# 7. Aliased #csv_split to #split_csv as per 6.  
# 8. Improved the debugging switches so that they are now a Hash.  
# 9. The quote to use when line splitting can now be specified in the call to #csv_split and via reference to it having been set elsewhere via @quote.  
# 10. To that (Change#9) end I now have the same list of quote types as in the #to_csv methods.  
# 11. I added unquoted options to the quote types.  
# 12. Created Array#to_csv to refactor both the Hash and CSVFile#to_csv stuff, so the bulk of both of those methods has been gutted and moved to Array#to_csv.  
# 0/1
# 13. Moved what remained of CSVFile#to_csv into #write_line and deleted CSVFile#to_csv.  
# 14. Created Array#wrap_each (formerly called just wrap) to simplify Array#to_csv.  
# 15. Fixed a small error in logic with #write_line.  It is difficult when a method accepts all manner of inputs.  I was a little confused again about what's a Hash and what's an Array.  
# 16. Fixed a small scoping problem on Array#wrap_each.  'a' wasn't accessible outside the loop.  
# 1/2
# 17. Compressed #write_csv and #write_line.  Possibly more readable, possibly not.  
# 18. Did the same (compresses) for Array#wrap_each.  
# 19. Added String#wrap to be used in conjunction with Array#wrap_each and changed Array#wrap_each accordingly.  

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
# 12. Change String#csv_split, so as it will identify if there are no commas as well.  While this seems very unlikely for it to not find any commas at all, it is possible that what is supplied is complete crap and at least the process might halt there.  It does this as of long time back...  0.1.1!  However, what of when there is only one column of data?  Either I need the ability to go to 'manual' or I take this out.  
# *13. Get the lineno method working (if possible) because while what I have done is working OK, it is a little inelegant.  
# *14. Align method names to more closely match those of File.  
# *15. Put the option to specify quoting into to_csv and possibly remove it from #init.  
# *16. When strict is specified, do some checks for column count consistency, and possibly reapply checks for data consistency as per the idea (Did I write this idea down?) to attempt to automatically detect if there is a header line by comparing the data of the first line with subsequent lines (by way of column length, type, and anything else I can figure to use).  So, I'd need to write that in a sufficiently general way to be used in both contexts.  

# Ideas: 
# 1. Subclass CSVFile from File.  I'm not sure what this gets me, but it occurred to me that I have a read method and I was thinking of applying a close to an instance of the CSVFile class, and of course I don't have one.  Done as of 0.2.0.  As of 0.4.9, this is still not quite working right---particularly the write method clash, so started 0.2.0 might be a better way to put it.  
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
# 7. Header lines are not being written out either as the default, nor even if such is specified.  

$debug = {}
$debug[:csv_split] = false
$debug[:write_line] = true
$debug[:each] = false
$debug[:first_line] = false
$debug[:wrap_each] = false
$debug[:Array_to_csv] = false

require 'pp' if (b = false; $debug.each{|method, debug| b = true if debug}; b)

class String
  
  def csv_split(quote = nil)
    if @quote && !quote # If a file-wide quoting format is specified and no quoting has been explicitly set for this call, then use the file-wide value, rather than interpolating.  
      quote = @quote
    end
    unless quote # then auto-parse...  
      pp self if $debug[:csv_split]
      quote = :double
      double = self.match(/",|,\s"/)
      pp double if $debug[:csv_split]
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
    end # unless quote
    result = ''
    pp quote if $debug[:csv_split]
    case quote.to_sym # Also handles 'double', 'double_qoute', ...
      when :double, :double_quote, :double_quotes, :double_quoted, :doubly_quoted # No spaces, but no integrity checks.  
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
      when :strict_double, :strict_double_quote, :strict_double_quotes, :strict_double_quoted, :strict_doubly_quoted
      when :spacey_double, :spacey_double_quote, :spacey_double_quotes, :spacey_double_quoted, :spacey_doubly_quoted
      when :single, :single_quote, :single_quotes, :single_quoted, :singly_quoted
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
      when :strict_single, :strict_single_quote, :strict_single_quotes, :strict_single_quoted, :strict_singly_quoted
      when :spacey_single, :spacey_single_quote, :spacey_single_quotes, :spacey_single_quoted, :spacey_singly_quoted
      when :none, :no_quotes, :not_quoted, :unquoted
        result = self.chomp.split(/,\s*/)
      when :strict_none, :strict_no_quote, :strict_not_quoted, :strict_unquoted # I don't know what this does, since there isn't any quoting to play with, I know it simply does integrity checks!...  
      when :spacey_none, :spacey_no_quote, :spacey_not_quoted, :spacey_unquoted
    end # case quote
    pp result if $debug[:csv_split]
    result
  end # def csv_split
  alias_method :split_csv, :csv_split
  
  # Does strictness automatically denote that integrity checks like column count equivalance is enforced?  I suggest so, since I doubt that anyone would want to strictly enforce quoting and not column count.  At some later stage I *may* allow this, but it is a really low priority.  
  
  def wrap(wrapper)
    wrapper + self + wrapper
  end
  
end # class String

class Array
  
  def to_csv(quote)
    pp self if $debug[:Array_to_csv]
    case quote.to_sym # Also handles 'double', 'double_qoute', ...
      when :double, :double_quote, :double_quotes, :double_quoted, :doubly_quoted
        return self.wrap_each('"').join(',')
      when :strict_double, :strict_double_quote, :strict_double_quotes, :strict_double_quoted, :strict_doubly_quoted
        return self.wrap_each('"').join(',')
      when :spacey_double, :spacey_double_quote, :spacey_double_quotes, :spacey_double_quoted, :spacey_doubly_quoted
        return self.wrap_each('"').join(', ')
      when :single, :single_quote, :single_quotes, :single_quoted, :singly_quoted
        return self.wrap_each("'").join(',')
      when :strict_single, :strict_single_quote, :strict_single_quotes, :strict_single_quoted, :strict_singly_quoted
        return self.wrap_each("'").join(',')
      when :spacey_single, :spacey_single_quote, :spacey_single_quotes, :spacey_single_quoted, :spacey_singly_quoted
        return self.wrap_each("'").join(', ')
      when :none, :no_quotes, :not_quoted, :unquoted
        return self.join(',')
      when :strict_none, :strict_no_quotes, :strict_not_quoted, :strict_unquoted
        return self.join(',')
      when :spacey_none, :spacey_no_quotes, :spacey_not_quoted, :spacey_unquoted
        return self.join(', ')
    end # case
  end # def to_csv
  
  def wrap_each(wrapper)
    pp self if $debug[:wrap_each]
    a = []
    each{|e| a << e.wrap(wrapper)}
    a
  end
  alias_method :wrap_each_with, :wrap_each
  alias_method :wrap_each_with___, :wrap_each
  
end # class Array

class Hash
  
  def write(file, *desired_columns) # Passing in the file_handle is a horrible kludge.  Should I subclass Hash for a CSVLine object?  
    @file = file
    case desired_columns[0] # If I don't check for this, then by the time to_csv is called it might be possible that the atomic bits are two levels deep.  
      when Array
        file.puts(self.to_csv(desired_columns[0]))
      else
        file.puts(self.to_csv(desired_columns))
    end # case
  end # def write
  alias_method :write_line, :write
  alias_method :writeline, :write
  alias_method :writeln, :write
  
  def to_csv(*desired_columns)
    collector = []
    case desired_columns[0]
      when Array
        if desired_columns[0]
          desired_columns[0].each do |c| # Here is where re-ordering happens.  
            collector << self[c]
          end
        elsif @file.columns?
          file.columns.each do |k, v|
            collector << self[v]
          end
        else
          each do |k, v| # Assuming that the keys remain the same for each line, this should produce the same ordering of columns, but not the same as that entered...  
            collector << self[v]
          end
        end
      else
        if desired_columns
          desired_columns.each do |c|
            collector << self[c]
          end
        elsif @file.columns?
          file.columns.each do |k, v|
            collector << self[v]
          end
        else
          each do |k, v|
            collector << self[v]
          end
        end
    end # case
    pp collector if $debug
    collector.to_csv(@quote)
  end # def to_csv
  
end # class Hash

class CSVFile < File
  
  attr_accessor :lines, :quote
  alias_method :rows, :lines
    
  def initialize(filename, header_line = true, quote = :double, mode = 'r', permissions = nil)
    @filename, @header_line, @quote, @mode = self.class.expand_path(filename), header_line, quote, mode
    super(filename, mode, permissions)
    @columns = columns if header_line && ['r', 'r+', 'a+'].include?(mode)
    @attributes = attributes if header_line && ['r', 'r+', 'a+'].include?(mode)
    @lines = []
  end
  
  def read(*columns)
    pp columns if $debug[:each]
    number_of_columns = first_line.csv_split.size
    @header_line ? (rewind; gets) : rewind # Start at line 0 or line 1.  #lineno wasn't working when I first wanted this, but I will try #lineno again at some stage.  
    #pp @header_line if $debug
    case columns[0]
      when Array
        if columns[0] == [] # then select all columns by default...
          if @columns # then select by column name...  
            columns = @columns.collect {|k, v| k}
          else # select by column position...  
            columns = 0..(number_of_columns - 1)
          end
        else
          columns = columns[0]
        end # outer if
      else # the first item is (and presumably subsequent items are) somewhat more atomic...
        if columns == [] # then select all columns by default...
          if @columns # then select by column name...  
            columns = @columns.collect {|k, v| k}
          else # select by column position...  
            columns = 0..(number_of_columns - 1)
          end
        else
          columns = columns # Redundant, but so as to be explicit.  
        end # outer if
    end # case
    #pp columns if $debug
    file_each do |line|
      #pp line if $debug
      h = {}
      if @columns # then select by column name...  
        if columns == []
          i = -1
          parse_line(line).each do |column|
            h[@columns[(i += 1)]] = column
          end
        else
          columns.each do |column|
            h[column] = parse_line(line, column)
          end
        end
      else # select by column position...  
        if columns == []
          i = -1
          parse_line(line).each do |column|
            h[i += 1] = column
          end
        else
          columns.each do |column|
            h[column.to_i] = parse_line(line, column.to_i)
          end
        end
      end
      @lines << h
      #pp @lines if $debug
    end
    if @mode == 'r+'
      rewind
      truncate(0)
    end
    @lines
  end # def read
  alias_method :parse, :read
  
  def read_line(line, column = nil)
    if column
      case column
        when Integer
          line.csv_split[column]
        else
          line.csv_split[@columns[column.to_s]]
      end
    else
      line.csv_split
    end
  end
  alias_method :parse_line, :read_line
  alias_method :readln, :read_line
  alias_method :readline, :read_line
  
  alias_method :std_write, :write
  
  def write_csv(*columns)
    pp columns if $debug[:write]
    each{|line| write_line(line, *columns)}
  end
  
  def write_line(line, *columns)
    pp line, columns if $debug[:write_line]
    a = []
    pp columns[0] if $debug[:write_line]
    case columns[0]
      when Array
        columns[0] ? columns[0].each{|c| a << line[c]} : @columns.each{|k, v| a << line[v]}
      else
        columns ? columns.each{|c| a << line[c]} : @columns.each{|k, v| a << line[v]}
    end # case
    pp a if $debug[:write_line]
    self.puts(a.to_csv(@quote))
  end # def write_line
  alias_method :writeln, :write_line
  alias_method :writeline, :write_line
  
  alias_method :std_each, :each
  alias_method :std_file_each, :each
  alias_method :file_each, :each
  
  def each(*columns)
    pp columns if $debug[:each]
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
  
  def each_with_columns(*desired_columns)
    case desired_columns[0] # Check that this isn't conflicting with #columns.  It may be.  
      when Array
        if desired_columns[0]
          if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
            @lines.each {|line|
              yield desired_columns[0].collect {|c| line[c]}
            }
          else
            read(desired_columns[0]).each {|line|
              yield desired_columns[0].collect {|c| line[c]}
            }
          end # inner if
        else
          read.each {|line|
            yield @attributes.collect {|a| line[a]} # I assume that I need to use attributes here too.  
          }
        end # outer if
      else
        if desired_columns != []
          if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
            @lines.each {|line|
              yield desired_columns.collect {|c| line[c]}
            }
          else
            read(desired_columns).each {|line|
              yield desired_columns.collect {|c| line[c]}
            }
          end # inner if
        else
          read.each {|line|
            #yield @columns.collect {|k,v| line[k]} # I really do not understand why this doesn't work.  I'm leaving this here because it is so annoying that I don't get how it works.  
            yield @attributes.collect {|a| line[a]}
          }
        end # outer if
    end # case
  end
  
  def columns
    pp '#columns' if $debug[:each]
    @columns ||= (
      if @header_line  
        h = {}
        i = -1
        first_line.csv_split.each do |key|
          h[key.gsub(/ /, '_').chomp] = (i += 1) # I may remove the underscore substitution, but then symbols are in a bit of strife...
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
      if @header_line
        a = []
        first_line.csv_split.each do |attribute|
          a << attribute
        end
        a
      else
        nil
      end
    )
  end
  
  private
  
  def first_line
    pp self if $debug[:first_line]
    self.rewind
    return_value = self.gets
    self.rewind
    pp return_value if $debug[:first_line]
    return_value
  end
  
  def lines?
    @lines[0]
  end
  alias_method :read?, :lines?
  
end # class CSVFile
