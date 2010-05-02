# CSVFile.rb

# 2010.05.03
# 0.8.2

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

# Changes since 0.7: 
# 1. A significant change to the CSVFile.new interface.  I should probably bump it to 0.8.0.  This breaks compatibility with the File.new method which I was wanting...  
# 0/1
# 2. Simplified the CSVFile.new, @mode options.  
# 1/2
# 3. Removed some requires, since I have a general purpose loader CSVFile.rb to load files in the CSVFile library now.  
# 4. + attr_accessor :mode.  

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

$profile = false
require 'profile' if $profile
require 'pp'

require 'Array/extract_optionsX'
require '_meta/default_to'

class CSVFile < File
  
  class << self
    
    attr_accessor :rows, :quote
    alias_method :lines, :rows
    
    def open(filename, *args)
      csv_file = new(filename, *args)
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
    
    def each(filename, row_separator = "\n", &block)
      open(filename) do |csv_file|
        csv_file.each(row_separator, &block)
      end
    end
    alias_method :foreach, :each
    
    def read_rows(filename, row_separator = "\n", *desired_columns)
      csv_file = new(filename)
      csv_file.read_csv(row_separator, *desired_columns)
    end
    alias_method :readrows, :read_rows
    alias_method :readlines, :read_rows
    alias_method :read_lines, :read_rows
    
    def read(filename, *desired_columns)
      read_rows(filename, *desired_columns)
    end
    alias_method :read_csv, :read
    alias_method :parse, :read
    alias_method :parse_csv, :read
    
    def write_rows(filename, row_separator = "\n", *desired_columns)
      csv_file = new(filename, true, :double, 'w')
      csv_file.write_csv(*desired_columns)
    end
    alias_method :writerows, :write_rows
    alias_method :writelines, :write_rows
    alias_method :write_lines, :write_rows
    
    def write(filename, *desired_columns)
      write_rows(filename, *desired_columns)
    end
    alias_method :write_csv, :write
    
    def header_row(filename)
      csv_file = new(filename)
      csv_file.header_row
    end
    
    def first_row(filename)
      csv_file = new(filename)
      csv_file.first_row
    end
    
    def attributes(filename)
      csv_file = new(filename)
      csv_file.attributes
    end
    
    def columns(filename)
      csv_file = new(filename)
      csv_file.columns
    end
    
  end # class << self
  
  include Enumerable
  
  attr_accessor :rows, :quote, :header_row, :mode
  alias_method :lines, :rows
  
  def initialize(filename, *args)
    options = args.extract_options!
    @header_row = options[:header_row].default_is(true)
    @quote = options[:quote].default_is(:double)
    @filename = self.class.expand_path(filename)
    @mode = options[:mode].default_is('r')
    permissions = options[:permissions].default_is(nil)
    unless @header_row.class == TrueClass || @header_row.class == FalseClass
      @header_row = (
        case @header_row.to_sym
        when :header_row, :header_line, :header, :heading; true
        when :no_header_row, :no_header_line, :no_header, :no_heading; false
        else; true # unrecognised attempt at specifying a header line, so just assume so anyway.  Let any errors be caught as they may further on...  
        end
      )
    end
    @mode = (
      case @mode.to_s # It can handle :read, :write, ...
      when 'r', 'r+', 'w', 'w+', 'a', 'a+'; mode.to_s
      when 'read', 'read_only', 'readonly'; 'r'
      when 'rw', 'read_write', 'readwrite'; 'r+'
      when 'write', 'write_only', 'writeonly'; 'w'
      when 'wr'; 'w+'
      when 'append'; 'a'
      when 'rw_append', 'read_write_append', 'readwrite_append'; 'a+'
      else 'r' # unrecognised attempt at specifying a mode, so just make it read.  Let any errors be caught as they may further on...  
      end
    )
    super(@filename, @mode, permissions)
    @columns = columns if header_row? && ['r', 'r+', 'a+'].include?(@mode)
    @rows = []
  end
  
  def read(row_separator = "\n", *desired_columns)
    read_header
    desired_columns = set_columns(*desired_columns)
    do_read(desired_columns)
  end
  alias_method :read_csv, :read
  alias_method :parse, :read
  alias_method :parse_csv, :read
  
  def set_columns(*desired_columns)
    case desired_columns[0]
    when Array
      if desired_columns[0] == [] # then select all columns by default...
        if @columns # then select by column name...  
          @columns.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]}
        else # select by column position...  
          0..(number_of_columns - 1)
        end
      else
        @columns[0] # I could check that what is provided really is a column, for when @columns exists by having an additional if here.  
      end
    else # the first item is (and presumably subsequent items are) somewhat more atomic...  
      if columns == [] # then select all columns by default...
        if @columns # then select by column name...  
          @columns.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]}
        else # select by column position...  
          0..(@columns.size - 1)
        end
      else
        @columns
      end
    end
  end
  
  def do_read(columns, row_separator = "\n")
    file_each(row_separator) do |raw_row|
      parsed_row = {}
      if columns? # then select by column name
        i = -1
        parse_row(raw_row).each{|column_value| parsed_row[attributes[i += 1]] = column_value}
      else # select by column position
        i = -1
        parse_row(raw_row).each{|column_value| parsed_row[i += 1] = column_value}
      end
      @rows << parsed_row
    end
    (rewind; truncate(0)) if @mode == 'r+'
    @rows
  end
  
  def read_header
    columns
    header_row? ? (rewind; gets) : rewind # Start at line 0 or line 1.  #lineno wasn't working when I first wanted this, but I will try #lineno again at some stage.  
  end
  
  def read_row(row, column = nil)
    if column
      case column
      when Integer
        row.csv_split(quote)[column]
      else
        row.csv_split(quote)[columns[column.to_s]]
      end
    else
      row.csv_split(quote)
    end
  end
  alias_method :readrow, :read_row
  alias_method :read_line, :read_row
  alias_method :readline, :read_row
  alias_method :parse_row, :read_row
  alias_method :parse_line, :read_row
  
  def write(*columns)
    write_header(*columns) if header_row?
    each{|row| write_row(line, *columns)}
  end
  alias_method :write_csv, :write
  
  def write_header(*columns)
    case columns[0]
    when Array
      columns[0] != [] ? write_line(columns[0].to_csv) : write_line(attributes.to_csv)
    else
      columns != [] ? write_line(columns.to_csv) : write_line(attributes.to_csv)
    end
  end
  
  def write_row(line, *columns)
    collector = []
    case columns[0]
    when Array
      columns[0] != [] ?
        columns[0].each{|c| collector << line[c] unless line[c].nil?} :
        attributes.each{|column| collector << line[column] unless line[column].nil?}
    else
      columns != [] ?
        columns.each{|c| collector << line[c] unless line[c].nil?} :
        attributes.each{|column| collector << line[column] unless line[column].nil?}
    end
    puts(collector.to_csv(quote))
  end
  alias_method :write_line, :write_row
  alias_method :writeline, :write_row
  alias_method :writerow, :write_row
  
  alias_method :std_each, :each
  alias_method :std_file_each, :each
  alias_method :file_each, :each
  def each(row_separator = "\n", *columns)
    if rows?
      rows.each{|line| yield line}
    else # nothing has been read yet...
      if columns != []
        read_csv(row_separator, columns).each do |line|
          yield columns.collect{|c| line[c]}
        end
      else
        read_csv(row_separator).each{|line| yield line}
      end
    end
  end
  alias_method :each_csv, :each
  alias_method :csv_each, :each
  alias_method :each_with_row, :each
  alias_method :each_with_line, :each
  
  def each_with_columns(row_separator = "\n", *desired_columns)
    case desired_columns[0]
    when Array
      if desired_columns[0]
        if rows?
          rows.each do |row|
            yield desired_columns[0].collect{|c| row[c]}
          end
        else
          read_csv(row_separator, desired_columns[0]).each  do |row|
            yield desired_columns[0].collect{|c| row[c]}
          end
        end # inner if
      else
        read_csv.each do |row|
          yield attributes.collect{|a| row[a]} # I assume that I need to use attributes here too.  
        end
      end # outer if
    else
      if desired_columns != []
        if rows?
          rows.each do |row|
            yield desired_columns.collect{|c| row[c]}
          end
        else
          read_csv(desired_columns).each do |row|
            yield desired_columns.collect{|c| row[c]}
          end
        end # inner if
      else
        read_csv.each do |row|
          yield attributes.collect{|a| row[a]}
        end
      end # outer if
    end # case
  end
  
  def columns(row_separator = "\n")
    @columns ||= (
      if header_row?
        h, i = {}, -1
        first_row(row_separator).csv_split.each{|key| h[key.gsub(/ /, '_').chomp.to_sym] = (i += 1)} # I may remove the underscore substitution, but then symbols are in a bit of strife...
        h
      else
        nil
      end
    )
  end
  
  def columns=(*column_order)
    @columns = {}
    case column_order[0]
    when Hash
      column_order[0].each{|column_name, column_position| @columns[column_name.to_s] = column_position}
    when Array
      i = -1
      column_order[0].each{|column| @columns[column.to_s] = (i += 1)}
    else
      i = -1
      column_order.each{|column| @columns[column.to_s] = (i += 1)}
    end
  end
  
  def columns?
    columns != nil
  end
  
  def attributes
    @attributes ||= (
      columns ? columns.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]} : nil
    )
  end
  alias_method :headers, :attributes
  
  def header_row?
    @header_row
  end
  alias_method :header_line?, :header_row?
  
  def first_row(row_separator = "\n")
    self.rewind
    return_value = self.gets(row_separator)
    self.rewind
    return_value
  end
  alias_method :first_line, :first_row
  
  def rows?
    @rows[0]
  end
  alias_method :lines?, :rows?
  alias_method :read?, :rows?
  
end # class CSVFile
