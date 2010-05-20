# SimpleCSV

# 2010.05.21
# 0.9.1

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
# 11. Simplify some more!  

# Ideas: 
# 1. Standardize on either symbols or strings for column names, since presently one has to be consistent.  It would be nicer to be able to mix and match---if possible.  
# 2. Automatically detect as to whether there is a header line by taking the first line and comparing the types (alpha, numeric, alpha-numeric, etcetera) with each of the column values with those of the subsequent 2 or 3 or so lines and if there is a correspondence, then assume that there is a header line.  This would mean that the assumption that there is would change and that if the guess was wrong that it would need to be made explict.  
# 3. Have it #read a file automatically if any of 'r' or 'r+' or 'w+' is given as the mode.  
# 4. Finally try to make use of Index instead of Hash, since that library file is still hanging around.  Using this class may be simpler but not faster than using Hash and Array.  

# Bugs: 
# 1. This did cope with commas within a quoted CSV file, however while I think I broke this again with 0.9.0, I'm not sure that I ever had it working properly.  

# Changes since 0.8: 
# 1. /CSVFile/SimpleCSV/.  
# 2. Reset the Todo list and rolled in the Goals to that.  
# 3. Moved the loader stuff (Array, Hash, String) in here.  
# 4. More changes to interfaces to reflect the change in 0.8.0 to interface arguments.  

require 'profile' if true
require 'pp'

require 'stringio'

require 'File/relative_path'
$LOAD_PATH << File.expand_path(File.relative_path('lib'))

require '_meta/default_to'
require 'Array/extract_optionsX'
require 'Array/to_csv'
require 'Hash/to_csv'
# require 'Index'
require 'String/split_csv'

class SimpleCSV
  
  class << self
    
    attr_accessor :rows, :quote
    alias_method :lines, :rows
    
    def open(source, *args)
      csv_file = new(source, *args)
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
    
    def each(filename, *args, &block)
      options = args.extract_options!
      open(filename, *args) do |csv_file|
        if options[:columns]
          csv_file.each(options[:columns], &block)
        else
          csv_file.each(&block)
        end
      end
    end
    alias_method :foreach, :each
    
    def read_rows(filename, *args)
      csv_file = new(filename, *args)
      options = args.extract_options!
      if options[:columns]
        csv_file.read_csv(options[:columns])
      else
        csv_file.read_csv
      end
    end
    alias_method :readrows, :read_rows
    
    def read(filename, *args)
      read_rows(filename, *args)
    end
    alias_method :read_csv, :read
    alias_method :parse, :read
    alias_method :parse_csv, :read
    
    def write_rows(filename, *args)
      csv_file = new(filename, *args)
      options = args.extract_options!
      csv_file.write_csv(options[:columns])
    end
    alias_method :writerows, :write_rows
    
    def write(filename, *args)
      write_rows(filename, *args)
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
  
  attr_accessor :rows, :quote, :header_row
  alias_method :lines, :rows
  
  def initialize(source, *args)
    options = args.extract_options!
    @header_row = options[:header_row].default_is(false)
    @quote = options[:quote].default_is(:double)
    @row_separator = options[:row_separator].default_is("\n")
    @desired_columns = (options[:desired_columns] || options[:columns])
    unless @header_row.class == TrueClass || @header_row.class == FalseClass
      @header_row = (
        case @header_row.to_sym
        when :header_row, :header_line, :header, :heading; true
        when :no_header_row, :no_header_line, :no_header, :no_heading; false
        else; true # unrecognised attempt at specifying a header line, so just assume so anyway.  Let any errors be caught as they may further on...  
        end
      )
    end
    @mode = options[:mode].default_is('r')
    @source = (
      unless File.exist?(source)
        StringIO.new(source)
      else
        @filename = File.expand_path(source)
        @mode = (
          case options[:mode].to_s
          when 'r', 'r+', 'w', 'w+', 'a', 'a+'; options[:mode].to_s
          when 'read', 'read_only', 'readonly'; 'r'
          when 'rw', 'read_write', 'readwrite'; 'r+'
          when 'write', 'write_only', 'writeonly'; 'w'
          when 'wr'; 'w+'
          when 'append'; 'a'
          when 'rw_append', 'read_write_append', 'readwrite_append'; 'a+'
          else 'r' # unrecognised attempt at specifying a mode, so just make it read.  Let any errors be caught as they may further on...  
          end
        )
        permissions = options[:permissions].default_is(nil)
        File.new(source, @mode, permissions)
      end
    )
    @columns = columns if header_row? && ['r', 'r+', 'a+'].include?(@mode)
    @rows = []
  end
  
  def close
    @source.close
  end
  
  def read(*selected_columns)
    @source.each(@row_separator) do |raw_row|
      @rows << parse_row(raw_row, *selected_columns)
    end
    (@source.rewind; @source.truncate(0)) if @mode == 'r+'
    @rows
  end
  alias_method :read_csv, :read
  alias_method :parse, :read
  alias_method :parse_csv, :read
  
  def columns
    @columns ||= (
      if header_row?
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
  
  def read_header
    columns
    if header_row?
      (@source.rewind; @source.gets(@row_separator))
    else
      @source.rewind
    end
  end
  
  def read_row(raw_row, *selected_columns)
    parsed_row = {}
    if selected_columns.empty?
      if columns?
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
  alias_method :parse_row, :read_row
  
  def write(*columns)
    write_header(*columns) if header_row?
    each{|row| write_row(line, *columns)}
  end
  alias_method :write_csv, :write
  
  def write_header(*columns)
    columns.flatten!
    if columns.empty?
      write_row(attributes.to_csv)
    else
      write_row(columns.to_csv)
    end
  end
  
  def write_row(line, *columns)
    collector = []
    columns.flatten!
    if columns.empty?
      attributes.each{|column| collector << line[column] unless line[column].nil?}
    else
      columns.each{|c| collector << line[c] unless line[c].nil?}
    end
    @source.puts(collector.to_csv(quote))
  end
  
  def each(*columns)
    if rows?
      rows.each do |line|
        yield line
      end
    else # nothing has been read yet...
      if columns.empty?
        read_csv.each do |line|
          yield line
        end
      else
        read_csv(columns).each do |line|
          yield columns.collect{|c| line[c]}
        end
      end
    end
  end
  
  def each_with_columns(*selected_columns)
    selected_columns.flatten!
    if selected_columns.empty?
      read_csv.each do |row|
        yield attributes.collect{|a| row[a]}
      end
    else
      if rows?
        rows.each do |row|
          yield desired_columns.collect{|c| row[c]}
        end
      else
        read_csv(desired_columns).each do |row|
          yield desired_columns.collect{|c| row[c]}
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
  
  def rows?
    @rows[0]
  end
  
  def header_row?
    @header_row
  end
  alias_method :header_line?, :header_row?
  
  def columns?
    columns != nil
  end
  
  def first_row
    @source.rewind
    return_value = @source.gets(@row_separator)
    @source.rewind
    return_value
  end
  alias_method :first_line, :first_row
  
end # class SimpleCSV

CSVFile = SimpleCSV
CSVString = SimpleCSV
