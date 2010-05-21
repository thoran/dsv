# SimpleCSV

# 2010.05.21, 22
# 0.9.2

# Description: A CSV object for reading and writing CSV (and similar) text files with tabulated data to and from files and strings.  

# Todo: 
# 1. Have it be able to read mixed CSV files.  Done as of 0.9.0.  
# 2. Have it be able to read escaped and quoted delimeters.  
# 3. Separate out the different classes into separate files.  Done as of 0.8 I think, but taken further with 0.9.  
# 4. Create a gem and/or Rubylibify and/or 
# 5. Optionally do line counts.  
# 6. Optionally do column count checks.  
# 7. Optionally do data consistency checks for column length, type, and anything else that makes sense.  
# 8. Put the option to specify quoting into to_csv and possibly remove it from #init.  Done as of at least 0.8.  
# 9. Remove underscores when outputting the header line, but only if they were added---and only if they're wanting to be removed?...  As of 0.9.0, I just use strings anyway.  
# 10. Reorder the conditionals in #write_line and #write_header.  Done as of 0.9.0.  
# 11. Simplify some more!  Done as of 0.9.1.  

# Ideas: 
# 1. Standardize on either symbols or strings for column names, since presently one has to be consistent.  It would be nicer to be able to mix and match---if possible.  
# 2. Automatically detect as to whether there is a header line by taking the first line and comparing the types (alpha, numeric, alpha-numeric, etcetera) with each of the column values with those of the subsequent 2 or 3 or so lines and if there is a correspondence, then assume that there is a header line.  This would mean that the assumption that there is would change and that if the guess was wrong that it would need to be made explict.  
# 3. Have it #read a file automatically if any of 'r' or 'r+' or 'w+' is given as the mode.  
# 4. Finally try to make use of Index instead of Hash, since that library file is still hanging around.  Using this class may be simpler but not faster than using Hash and Array.  

# Bugs: 
# 1. This did cope with commas within a quoted CSV file, however while I think I broke this again with 0.9.0, I'm not sure that I ever had it working properly.  
# 2. SimpleCSV#write_row doesn't handle it if there are no attributes/columns defined.  It needs to work with CSV files with no column names.  

# Changes since 0.8: 
# 1. /CSVFile/SimpleCSV/.  
# 2. Reset the Todo list and rolled in the Goals to that.  
# 3. Moved the loader stuff (Array, Hash, String) in here.  
# 4. More changes to interfaces to reflect the change in 0.8.0 to interface arguments.  
# 0/1 (Mostly the changes have been to supporting libraries.)
# 0/2
# 5. ~ SimpleCSV.read, contains SimpleCSV.read_rows.  
# 6. ~ SimpleCSV.write, contains SimpleCSV.write_rows.  
# 7. ~ SimpleCSV.header_row, simplified.  
# 8. ~ SimpleCSV.first_row, simplified.  
# 9. ~ SimpleCSV.attributes, simplified.  
# 10. ~ SimpleCSV.columns, simplified.  
# 11. - attr_accessor :rows, :quote, not being used.  
# 12. - alias_method :lines, :rows, not being used.  
# 13. - SimpleCSV#each_with_columns, rolled into SimpleCSV#each.  
# 14. ~ SimpleCSV#each, rolled in SimpleCSV#each_with_columns and only output Hashes now.  
# 15. - alias_method :lines, :rows, since a line is an unparsed row.  
# 16. ~ SimpleCSV#initialize, it now makes use of SimpleCSV.source.  
# 17. + SimpleCSV.parse, since it behaves slightly differently now from when it was an alias of SimpleCSV.read.  
# 18. ~ SimpleCSV.read, is now tidier!  
# 19. ~ SimpleCSV.write, is also a bit tidier!  
# 20. + SimpleCSV.to_a, so as to give this sort of output.  
# 21. + SimpleCSV.source_type.  
# 22. + CSVFile#initialize.  
# 23. + CSVString#initialize.  
# 24. - require '_meta/default_to'.  
# 25. - SimpleCSV#columns?, and using @columns.empty? instead in SimpleCSV#parse_row, since it is faster not to make that method call every row.  
# 26. - SimpleCSV#read_row, now just SimpleCSV#parse_row.  
# 27. - SimpleCSV#read_header, since it wasn't being used.  
# 28. - SimpleCSV#rows?, using @rows[0] instead in SimpleCSV#each, since it is faster not to make that method call every row.  
# 29. + SimpleCSV#parse, so as to mirror the changes in the class interface.  
# 30. ~ SimpleCSV#read, so as to accommodate the creation of SimpleCSV#parse as per the class interface.  
# 31. - require 'Index' and the file from ./lib also, since it wasn't being used still.  

require 'stringio'

require 'File/relative_path'
$LOAD_PATH.unshift(File.expand_path(File.relative_path('lib')))

require '_meta/blankQ'
require 'Array/extract_optionsX'
require 'Array/peek_options'
require 'Array/to_csv'
require 'Hash/to_csv'
require 'String/split_csv'

class SimpleCSV
  
  class << self
    
    def source_type(source)
      if File.exist?(source)
        CSVFile
      else
        CSVString
      end
    end
    
    def open(source, *args)
      csv_file = source_type(source).new(source, *args)
      if block_given?
        begin
          yield csv_file
          csv_file
        ensure
          csv_file.close
        end
      else
        csv_file
      end
    end
    
    def each(source, *args, &block)
      open(source, *args){|csv_file| csv_file.each(&block)}
    end
    alias_method :foreach, :each
    
    def read(source, *args, &block)
      if block
        parse(source, *args, &block)
      else
        open(source, *args){|csv_file| csv_file.read_csv}
      end
    end
    alias_method :read_csv, :read
    
    def parse(source, *args, &block)
      if block
        each(source, *args, &block)
      else
        read(source, *args)
      end
    end
    alias_method :parse_csv, :parse
    
    def write(source, *args)
      open(source, *args){|csv_file| csv_file.write_csv}
    end
    alias_method :write_csv, :write
    
    def header_row(source)
      new(source).header_row
    end
    
    def first_row(source)
      new(source).first_row
    end
    
    def attributes(source)
      new(source).attributes
    end
    
    def columns(source)
      new(source).columns
    end
    
  end # class << self
  
  include Enumerable
  
  attr_accessor :header_row, :mode, :quote, :row_separator, :selected_columns, :use_array, :rows
  
  def initialize(source, *args)
    @source = (
      if source.is_a?(String)
        SimpleCSV.source_type(source)
      else
        source
      end
    )
    options = args.extract_options!
    @header_row = options[:header_row] || options[:headers] || options[:header] || false
    @mode ||= options[:mode] || 'r'
    @quote = options[:quote] || :double
    @row_separator = options[:row_separator] || "\n"
    @selected_columns = options[:selected_columns]
    @use_array = options[:use_array] || false
    @columns = (
      if options[:columns]
        columns = (options[:columns])
      else
        columns
      end
    )
    @rows = []
  end
  
  def close
    @source.close
  end
  
  def read(*selected_columns, &block)
    if block
      parse(*selected_columns, &block)
    else
      @source.each(@row_separator){|raw_row| @rows << parse_row(raw_row, *selected_columns)}
      (@source.rewind; @source.truncate(0)) if @mode == 'r+'
      @as_array ? to_a : @rows
    end
  end
  alias_method :read_csv, :read
  
  def parse(*selected_columns, &block)
    if block
      each(*selected_columns, &block)
    else
      read(*selected_columns)
    end
  end
  alias_method :parse_csv, :parse
  
  def columns
    @columns ||= (
      if header_row? && ['r', 'r+', 'a+'].include?(@mode)
        columns, i = {}, -1
        first_row.split_csv(@quote).each{|column_name| columns[column_name] = (i += 1)}
        columns
      else
        nil
      end
    )
  end
  
  def columns=(*column_order)
    @columns = {}
    column_order.flatten!
    if column_order[0].is_a?(Hash)
      column_order[0].each{|column_name, column_position| @columns[column_name.to_s] = column_position}
    else
      i = -1
      column_order.each{|column| @columns[column.to_s] = (i += 1)}
    end
  end
  
  def parse_row(raw_row, *selected_columns)
    parsed_row = {}
    if selected_columns.empty?
      if @columns.blank?
        i = -1
        raw_row.split_csv(@quote).each{|column_value| parsed_row[attributes[i += 1]] = column_value}
      else
        i = -1
        raw_row.split_csv(@quote).each{|column_value| parsed_row[i += 1] = column_value}
      end
    else
      selected_columns.flatten!
      case selected_columns[0]
      when Integer
        i = -1
        raw_row.split_csv(@quote).each{|column_value| parsed_row[i] = column_value unless !selected_columns.include?(i += 1)}
      else
        i = -1
        raw_row.split_csv(@quote).each{|column_value| parsed_row[attributes[i]] = column_value unless !selected_columns.include?(attributes[i += 1])}
      end
    end
    parsed_row
  end
  
  def write(*selected_columns)
    write_header(*selected_columns) if header_row?
    each{|row| write_row(line, *selected_columns)}
  end
  alias_method :write_csv, :write
  
  def write_header(*selected_columns)
    selected_columns.flatten!
    if selected_columns.empty?
      write_row(attributes.to_csv)
    else
      write_row(columns.to_csv)
    end
  end
  
  def write_row(row, *selected_columns)
    collector = []
    selected_columns.flatten!
    unless attributes.empty?
      if selected_columns.empty?
        attributes.each{|attribute| collector << row[attribute] unless row[attribute].nil?}
      else
        selected_columns.each{|column| collector << row[column] unless row[column].nil?}
      end
      @source.puts(collector.to_csv(@quote))
    end
  end
  
  def each(*selected_columns)
    selected_columns.flatten!
    if @rows[0]
      if selected_columns.empty?
        rows.each{|row| yield row}
      else
        rows.each do |row|
          yield selected_columns.inject({}){|hash, column_name| hash[column_name] = row[column_name]; hash}
        end
      end
    else
      if selected_columns.empty?
        read_csv.each{|row| yield row}
      else
        read_csv(selected_columns).each do |row|
          yield selected_columns.inject({}){|hash, column_name| hash[column_name] = row[column_name]; hash}
        end
      end
    end
  end
  
  def attributes
    @attributes ||= (
      if columns
        columns.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]}
      else
        nil
      end
    )
  end
  
  def header_row?
    @header_row
  end
  
  def first_row
    @source.rewind
    return_value = @source.gets(@row_separator)
    @source.rewind
    return_value
  end
  
  def to_a
    @rows.collect do |row|
      attributes.collect{|attribute| row[attribute]}
    end
  end
  
end # class SimpleCSV

class CSVFile < SimpleCSV
  
  def initialize(filename, *args)
    source = (
      filename = File.expand_path(filename)
      @mode = (
        case args.peek_options[:mode].to_s
        when 'r', 'r+', 'w', 'w+', 'a', 'a+'; args.peek_options[:mode].to_s
        when 'read_only', 'readonly'; 'r'
        when 'rw', 'read_write', 'readwrite'; 'r+'
        when 'write_only', 'writeonly'; 'w'
        when 'append'; 'a'
        else 'r'
        end
      )
      permissions = args.peek_options[:permissions]
      File.new(filename, @mode, permissions)
    )
    super(source, *args)
  end
  
end

class CSVString < SimpleCSV
  
  def initialize(string, *args)
    source = StringIO.new(string)
    super(source, *args)
  end
  
end
