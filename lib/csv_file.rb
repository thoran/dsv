# csv_file.rb

# 20071029
# 0.6.0.0

# Description: A CSV file object.  

# Goals for 0.5: 
# 1. Have it be able to read mixed CSV files.  
# 2. Have it be able to read escaped and quoted delimeters.  
# 3. Be able to use the standard File method names.  
# 4. Remove any unnecessary code.  
# 5. One or two of the Todo's...  
# 6. Fix the remaining bugs...  
# 7. Create a foreach method.  
# 8. Separate out the different classes into separate files.  
# 9. Create a gem.  

# Changes since 0.5: 
# 1. 

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

class String
  
  def csv_split(quote = nil)
    unless quote # then auto-parse...  
      quote = :double
      double = self.match(/",|,\s*"/)
      unless double
        quote = :single
        single = self.match(/',|,\s*'/) # Singly quoted CSV files are essentially unheard of, but who knows?  
        unless single
          quote = :none
          none = self.match(/,/)
          unless none
            raise RuntimeError, "This file doesn't have any commas in it.  Are you sure that this is a CSV file?"
          end # unless none
        end # unless single
      end # unless double
    end # unless quote
    pp quote if $debug[:String_csv_split]
    result = ''
    result = case quote.to_sym # Also handles 'double', 'double_quote', ...
      when :double, :double_quote, :double_quotes, :double_quoted, :doubly_quoted # No spaces, but no integrity checks.  
        result = self.gsub(/,/, ',""').gsub(/"""/, '"') # This too is ugly, but at least it might be faster!  
        result = result.chomp.split(/",\s*"/)
        #result = self.chomp.split(/",\s*"/) # For use when temporarily commenting out the above loop.  
        result[0].sub!(/^"/, '')
        result[result.size - 1].sub!(/"$|",$/, '')
        result
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
        self.chomp.split(/,\s*/)
      when :strict_none, :strict_no_quote, :strict_not_quoted, :strict_unquoted
        self.chomp.split(/,/)
      when :spacey_none, :spacey_no_quote, :spacey_not_quoted, :spacey_unquoted
        self.chomp.split(/,\s+/)
      when :mixed
        result = ''
        comma_found = false
        quote_found = false
        self.each_char do |c|
          case c
          when /,/
            if comma_found == true
              result << '""'
            end
            result << c
            quote_found = false
            comma_found = true
          when /"/
          	if quote_found == true
          	  result << c
      		end
      		result << c
      		quote_found = true
      		comma_found = false
          else
          	if !(quote_found && comma_found)
              result << c
            end
            quote_found = false
            comma_found = false
          end # case c
        end # self.each_char
        #pp result; exit
        a = result.csv_split(:strict_none)
        i = -1
        new_a = []
        loop do
          #pp i, a.size
          e = a[i += 1]
          pp i
          pp a[i]
          quotes_opened = true if e.opening_quote?
          if quotes_opened
            if e.opening_quote?
              j = i - 1
              new_a[i] = ''
              pp 'e...', e
              #until e.closing_quotes?
                #pp i, j
                #pp a[i], a[j]
                #pp new_a[i], a[j + 1]
                new_a[i] = new_a[i] + ',' + a[j += 1]
              #end # until
            elsif e.closing_quote? # closing
              new_a[i] = new_a[i] + ',' + a[j += 1]
              quotes_opened = false
            else
              new_a[i] = new_a[i] + ',' + a[j += 1]
            end # if e.opening_quote?
            i = j
          elsif e.neither_opening_nor_closing_quotes?
            new_a << e.quote
          end # if e.open_xor_closing_quote?
          pp new_a
          pp i, a.size
          break if i >= a.size
        end # loop
        result = new_a
    end # case quote
    result
  end # def csv_split
  alias_method :split_csv, :csv_split
  
  # Does strictness automatically denote that integrity checks like column count equivalance is enforced?  I suggest so, since I doubt that anyone would want to strictly enforce quoting and not column count.  At some later stage I *may* allow this, but it is a really low priority.  
  
  def wrap(wrapper)
    wrapper + self + wrapper
  end
  
  def unwrap(wrapper)
    sub(/^#{wrapper}/, '').sub(/#{wrapper}$/, '')
  end
  
  def quote(mark = '"')
    wrap(mark)
  end
  
  def unquote(mark = '"')
    unwrap(mark)
  end
  
  def wrap!(wrapper)
    sub!(/^/, wrapper).sub!(/$/, wrapper) # It was only way I could think to do things in place.  Should I change #wrap to match now?  
  end
  
  def unwrap!(wrapper)
    sub!(/^#{wrapper}/, '').sub!(/#{wrapper}$/, '')
  end
  
  def quote!(mark = '"')
    wrap!(mark)
  end
  
  def unquote!(mark = '"')
    unwrap!(mark)
  end
  
  def each_char
    (0..(self.size - 1)).each{|i| yield self[i, 1]}
  end
  
  def opening_quote?
    (self =~ /^"/) ? true : false
  end
  alias_method :opening_quotes?, :opening_quote?
  
  def closing_quote?
    (self =~ /"$/) ? true : false
  end
  alias_method :closing_quotes?, :closing_quote?
  
  def opening_and_closing_quotes?
    opening_quote? && closing_quote?
  end
  
  def opening_or_closing_quotes?
    opening_quote? || closing_quote?
  end
  
  def opening_xor_closing_quotes?
    (opening_quote? || closing_quote?) && !opening_and_closing_quotes?
  end
  
  def neither_opening_nor_closing_quotes?
    !opening_and_closing_quotes?
  end
  
end # class String

class Array
  
  def to_csv(quote = :double)
    pp self if $debug[:Array_to_csv]
    case quote.to_sym # Also handles 'double', 'double_qoute', ...
      when :double, :double_quote, :double_quotes, :double_quoted, :doubly_quoted
        return quote_each('"').join(',')
      when :strict_double, :strict_double_quote, :strict_double_quotes, :strict_double_quoted, :strict_doubly_quoted
        return quote_each('"').join(',')
      when :spacey_double, :spacey_double_quote, :spacey_double_quotes, :spacey_double_quoted, :spacey_doubly_quoted
        return quote_each('"').join(', ')
      when :single, :single_quote, :single_quotes, :single_quoted, :singly_quoted
        return quote_each("'").join(',')
      when :strict_single, :strict_single_quote, :strict_single_quotes, :strict_single_quoted, :strict_singly_quoted
        return quote_each("'").join(',')
      when :spacey_single, :spacey_single_quote, :spacey_single_quotes, :spacey_single_quoted, :spacey_singly_quoted
        return quote_each("'").join(', ')
      when :none, :no_quotes, :not_quoted, :unquoted
        return join(',')
      when :strict_none, :strict_no_quotes, :strict_not_quoted, :strict_unquoted
        return join(',')
      when :spacey_none, :spacey_no_quotes, :spacey_not_quoted, :spacey_unquoted
        return join(', ')
    end # case
  end # def to_csv
  
  def wrap_each(wrapper)
    collect{|e| e.wrap(wrapper)}
  end
  alias_method :wrap_each_with, :wrap_each
  alias_method :wrap_each_with___, :wrap_each
  
  def wrap_each!(wrapper)
    collect!{|e| e.wrap(wrapper)}
  end
  alias_method :wrap_each_with!, :wrap_each!
  alias_method :wrap_each_with___!, :wrap_each!
  
  def unwrap_each(wrapper)
    collect{|e| e.unwrap(wrapper)}
  end
  alias_method :unwrap_each_of, :unwrap_each
  alias_method :unwrap_each_of___, :unwrap_each
  
  def unwrap_each!(wrapper)
    collect!{|e| e.unwrap(wrapper)}
  end
  alias_method :unwrap_each_of!, :unwrap_each!
  alias_method :unwrap_each_of___!, :unwrap_each!
  
  def quote_each(mark = '"')
    wrap_each(mark)
  end
  
  def quote_each!(mark = '"')
    wrap_each!(mark)
  end
  
  def unquote_each(mark = '"')
    unwrap_each(mark)
  end
  
  def unquote_each!(mark = '"')
    unwrap_each!(mark)
  end
  
  def each_with_index
    collect_with_index.each{|e| yield e.first, e.last}
  end
  
  def collect_with_index
    i = -1
    collect{|e| [e, i += 1]}
  end
  
end # class Array

class Hash
  
  def write(file, *desired_columns) # Passing in the file_handle is a horrible kludge.  Should I subclass Hash for a CSVLine object?  That still doesn't guarantee access to the file object though, since I'd need to attach some reference to it to every line object.  It would be better if because of the context of a block that this message could be trapped and redirected somehow.  
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
    
    def open(filename, mode = 'r', permissions = nil, &block)
      @header_line = true
      @filename, @header_line = expand_path(filename), header_line
      super(filename, mode, permissions, block)
      @columns = columns if @header_line
      @lines = []
    end
    
    def readlines(filename, *desired_columns)
      csv_file = new(filename)
      csv_file.read_csv(*desired_columns)
    end
    alias_method :read_lines, :readlines
    
    def read(filename, *desired_columns)
      self.class.readlines(filename, *desired_columns)
    end
    alias_method :read_csv, :read
    
    def writelines(filename, *desired_columns)
      csv_file = new(filename, true, :double, 'w')
      csv_file.write_csv(*desired_columns)
    end
    alias_method :write_lines, :writelines
    
    def write(filename, *desired_columns)
      self.class.writelines(filename, *desired_columns)
    end
    alias_method :write_csv, :write
    
  end # class << self
  
  def read_csv(*columns)
    number_of_columns = first_line.csv_split.size
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
    file_each do |line|
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
  
  def each(*columns)
    pp columns if $debug[:each]
    if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
      @lines.each {|line| yield line}
    else # nothing has been read yet...
      if columns != [] # then 
        read_csv(columns).each do |line|
          yield columns.collect {|c| line[c]}
        end
      else
        read_csv.each {|line| yield line}
      end
    end # outer if
  end
  alias_method :csv_file_each, :each
  alias_method :each_with_line, :each
  
  def each_with_columns(*desired_columns)
    case desired_columns[0]
      when Array
        if desired_columns[0]
          if lines? # May have been more efficient to have left this as @lines[0], so do test this later...  
            @lines.each {|line|
              yield desired_columns[0].collect {|c| line[c]}
            }
          else
            read_csv(desired_columns[0]).each {|line|
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
  
  def columns
    pp '#columns' if $debug[:columns]
    @columns ||= (
      if @header_line  
        h = {}
        i = -1
        first_line.csv_split.each do |key|
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
