# SimpleCSV.rb
# SimpleCSV

# 20260910
# 0.11.4

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
# 1. This did cope with commas within a quoted CSV file, however while I think I broke this again with 0.9.0, I'm not sure that I ever had it working properly.  It works properly as of 0.9.3 at least.
# 2. Does SimpleCSV#write_row handle it if there are no attributes/columns defined?  It needs to work with CSV files with no column names.

$LOAD_PATH.unshift(File.expand_path('..', __FILE__))

require '_meta/blankQ'
require 'Array/extract_optionsX'
require 'Array/peek_options'
require 'Array/to_csv'
require 'Hash/to_csv'
require 'strscan'

require 'String/split_csv'

require 'SimpleCSV/File'
require 'SimpleCSV/String'

class SimpleCSV

  class UnterminatedQuote < StandardError; end

  QUOTED_FIELD = /(?:[^"]|"")*"/

  class << self

    def source_type(source)
      if ::File.exist?(source)
        SimpleCSV::File
      else
        SimpleCSV::String
      end
    end

    def open(source, *args, &block)
      @csv_file = new(source, *args)
      if block
        begin
          yield @csv_file
          @csv_file
        ensure
          @csv_file.close
        end
      else
        @csv_file
      end
    end

    def each(source, *args, &block)
      new(source, *args).each(&block)
    end
    alias_method :foreach, :each

    def collect(source, *args, &block)
      new_collection = []
      each(source, *args){|row| new_collection << block.call(row)}
      new_collection
    end
    alias_method :map, :collect

    def select(source, *args, &block)
      new_collection = []
      each(source, *args){|row| new_collection << row if block.call(row)}
      new_collection
    end
    alias_method :find_all, :select

    def reject(source, *args, &block)
      new_collection = []
      each(source, *args){|row| new_collection << row unless block.call(row)}
      new_collection
    end

    def detect(source, *args, &block)
      each(source, *args){|row| return row if block.call(row)}
    end
    alias_method :find, :detect

    # 20240826: Be able to select columns from here. The #read interface has that ability and so should the class method.
    def read(source, *args, &block)
      if block
        parse(source, *args, &block)
      else
        new(source, *args).read_csv
      end
    end
    alias_method :read_csv, :read

    # 20240826: Here to so as to be consistent. See .read() comment.
    def parse(source, *args, &block)
      if block
        each(source, *args, &block)
      else
        read(source, *args)
      end
    end
    alias_method :parse_csv, :parse

    def write(source, *args)
      new(source, *args).write_csv
    end
    alias_method :write_csv, :write

    def header_row(source, *args)
      new(source, *args).header_row
    end

    def first_row(source, *args)
      new(source, *args).first_row
    end

    def attributes(source, *args)
      new(source, *args).attributes
    end

    def columns(source, *args)
      new(source, *args).columns
    end

    def parse_line(raw_row, *args) # For FasterCSV compatibility.
      options = args.extract_options!
      row_separator = options[:row_separator] || options[:row_sep] || "\n"
      column_separator = options[:column_separator] || options[:col_sep] || ','
      sc = SimpleCSV.new(raw_row, :quote => nil, :as_array => true, :row_separator => row_separator, :column_separator => column_separator)
      sc.parse_row(raw_row)
    end

  end # class << self

  include Enumerable

  attr_accessor :header_row, :mode, :quote, :row_separator, :selected_columns, :as_array, :rows

  def initialize(source, *args)
    @source = (
      if source.is_a?(::String)
        SimpleCSV.source_type(source).new(source, *args).source
      else
        source
      end
    )
    options = args.extract_options!
    @header_row = options[:header_row] || options[:headers] || options[:header] || false
    @mode = options[:mode] || 'r'
    @quote = options[:quote] || nil
    @row_separator = options[:row_separator] || options[:row_sep] || "\n"
    @column_separator = options[:column_separator] || options[:col_sep] || ','
    @selected_columns = options[:selected_columns]
    @as_array = options[:as_array] || false
    @split_fields = field_splitter
    if options[:columns]
      self.columns = options[:columns]
    else
      self.columns
    end
    @rows = []
  end

  def close
    @source.close
  end

  def read(*selected_columns, &block)
    if block
      parse(*selected_columns, &block)
    else
      read_header
      @source.each_line(@row_separator){|raw_row| @rows << parse_row_across_lines(raw_row, *selected_columns)}
      @rows
    end
  end
  alias_method :read_csv, :read

  def read_header
    columns
    if header_row?
      (@source.rewind; @source.gets(@row_separator))
    else
      @source.rewind
    end
  end
  alias_method :read_csv_header, :read_header

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
      if header_row? && ['r', 'r+', 'a+'].include?(@mode) && (first_row = first_row?)
        columns, i = {}, -1
        fields_of(first_row).each do |column_name|
          if column_name.empty?
            columns[column_name].blank? ? columns[column_name] = [i += 1] : columns[column_name] << (i += 1)
          else
            columns[column_name] = (i += 1)
          end
        end
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
    i = -1
    if selected_columns.empty?
      if @columns.blank?
        fields_of(raw_row).each{|column_value| parsed_row[i += 1] = column_value}
      else
        fields_of(raw_row).each{|column_value| parsed_row[attributes[i += 1]] = column_value}
      end
    else
      selected_columns.flatten!
      case selected_columns[0]
      when Integer
        fields_of(raw_row).each{|column_value| parsed_row[i] = column_value unless !selected_columns.include?(i += 1)}
      else
        fields_of(raw_row).each{|column_value| parsed_row[attributes[i]] = column_value unless !selected_columns.include?(attributes[i += 1])}
      end
    end
    if @as_array
      if @columns.blank?
        (0..(parsed_row.size - 1)).inject([]){|a,i| a << parsed_row[i]}
      else
        attributes.collect{|attribute| parsed_row[attribute]}
      end
    else
      parsed_row
    end
  end

  # A quoted field may hold the row separator; the parser says so by raising, and the next line is added and the row parsed again, so that the ordinary row costs nothing for it.
  def parse_row_across_lines(raw_row, *selected_columns)
    parse_row(raw_row, *selected_columns)
  rescue UnterminatedQuote
    continuation = @source.gets(@row_separator) or raise(UnterminatedQuote, 'a quoted field is not closed before the end of the source')
    raw_row << continuation
    retry
  end

  # The splitter is chosen once, from the separator's kind and the quote mode, and thereafter runs with no further decision: a named mode is a direct string operation on the contract it names, and no mode is the automatic path, which scans only a row that holds a quote.
  def field_splitter
    return method(:scan_fields) if @column_separator.is_a?(::Array)
    case @quote&.to_sym
    when :none, :unquoted then method(:split_unquoted_fields)
    when :double, :double_quoted, :double_quotes then @column_separator.is_a?(::String) ? quoted_field_splitter('"') : method(:scan_fields)
    when :single, :single_quoted, :single_quotes then @column_separator.is_a?(::String) ? quoted_field_splitter("'") : method(:scan_fields)
    else @column_separator.is_a?(::String) ? method(:split_fields_or_scan) : method(:scan_fields)
    end
  end

  def fields_of(raw_row)
    @split_fields.call(raw_row.chomp(@row_separator))
  end

  def split_unquoted_fields(row)
    row.split(@column_separator, -1)
  end

  # A row under a quoted mode is wholly quoted or wholly unquoted, a header row commonly being the latter: a quoted row splits on quote-separator-quote, loses the outer quotes at its ends, and folds a doubled quote to one; an unquoted row splits plainly.
  def quoted_field_splitter(quote)
    boundary = quote + @column_separator + quote
    doubled = quote * 2
    ->(row){row.start_with?(quote) ? row.delete_prefix(quote).delete_suffix(quote).split(boundary, -1).collect{|field| field.gsub(doubled, quote)} : row.split(@column_separator, -1)}
  end

  def split_fields_or_scan(row)
    row.include?('"') ? scan_fields(row) : row.split(@column_separator, -1)
  end

  def scan_fields(row)
    scanner = StringScanner.new(row)
    fields = []
    index = -1
    until scanner.eos? && index >= 0 && !scanner.matched?
      separator = scan_separator_at(index += 1)
      fields << (scanner.peek(1) == '"' ? scan_quoted_field(scanner, separator) : scan_unquoted_field(scanner, separator))
      break unless scanner.matched?
    end
    fields
  end

  def scan_separator_at(index)
    @scan_separators ||= scan_separators
    @scan_separators.is_a?(::Array) ? (@scan_separators[index] || @scan_separators.last) : @scan_separators
  end

  def scan_separators
    separators = @column_separator.is_a?(::Array) ? @column_separator : [@column_separator]
    patterns = separators.collect{|separator| separator.is_a?(::Regexp) ? separator : Regexp.new(Regexp.escape(separator))}
    @column_separator.is_a?(::Array) ? patterns : patterns.first
  end

  # An unquoted field runs to the next separator, or to the end of the row, in which case nothing is matched and the caller stops.
  def scan_unquoted_field(scanner, separator)
    start = scanner.pos
    if scanner.scan_until(separator)
      scanner.string[start, scanner.pos - scanner.matched_size - start]
    else
      scanner.terminate
      scanner.string[start..]
    end
  end

  # A quoted field runs to the closing quote, a doubled quote within it being one quote, taken in one scan; the separator after it is consumed so that the caller continues, and its absence at the end of the row is the end.
  def scan_quoted_field(scanner, separator)
    scanner.getch
    chunk = scanner.scan(QUOTED_FIELD) or raise UnterminatedQuote
    scanner.scan(separator) || scanner.terminate
    chunk.chomp('"').gsub('""', '"')
  end

  def write(*selected_columns)
    prepare_to_rewrite if @mode == 'r+'
    write_header(*selected_columns) if header_row?
    each{|row| write_row(row, *selected_columns)}
  end
  alias_method :write_csv, :write

  # Under r+ a write replaces the file: the rows are read first if they have not been, then the file is emptied, once, here, rather than at the end of every read.
  def prepare_to_rewrite
    read_csv unless @rows[0]
    @source.rewind
    @source.truncate(0)
  end

  def write_header(*selected_columns)
    selected_columns.flatten!
    names = selected_columns.empty? ? attributes : selected_columns
    write_values(names)
  end
  alias_method :write_csv_header, :write_header

  def write_row(row, *selected_columns)
    collector = []
    selected_columns.flatten!
    unless attributes.blank?
      if selected_columns.blank?
        attributes.each{|attribute| collector << row[attribute] unless row[attribute].nil?}
      else
        selected_columns.each{|column| collector << row[column] unless row[column].nil?}
      end
      write_values(collector)
    end
  end
  alias_method :write_csv_row, :write_row

  def write_values(values)
    @source.puts(values.to_csv(@quote))
  end

  def each(*selected_columns)
    selected_columns.flatten!
    if @rows[0]
      if selected_columns.empty?
        @rows.each{|row| yield row}
      else
        @rows.each do |row|
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
  alias_method :each_row, :each

  def attributes
    @attributes ||= (
      if columns.blank?
        nil
      else
        a = []
        columns.each do |k,v|
          case v
          when Array
            v.each{|e| a << ['', e]}
          else
            a << [k, v]
          end
        end
        a.sort{|a,b| a[1] <=> b[1]}.collect{|a| a[0]}
      end
    )
  end

  def attributes=(attributes)
    @attributes = attributes
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
  alias_method :first_row?, :first_row

  def to_a
    read_csv unless @rows[0]
    if @as_array
      @rows
    elsif @columns.blank?
      result = []
      @rows.each do |row|
        a = []
        (0..(row.size - 1)).inject([]){|a,i| a << row[i]}
        result << a
      end
      result
    else
      @rows.collect do |row|
        attributes.collect{|attribute| row[attribute]}
      end
    end
  end

end # class SimpleCSV
