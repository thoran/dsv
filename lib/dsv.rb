# dsv.rb
# DSV

# frozen_string_literal: true

# Description: Delimiter-separated values: reading and writing CSV and its relatives, tabulated data to and from files and strings, with any delimiter on either side.

require 'stringio'

require 'DSV/VERSION'
require 'DSV/File'
require 'DSV/String'
require 'DSV/Error'
require 'DSV/UnterminatedQuote'
require 'DSV/UnexpectedRow'
require 'DSV/UnquotedField'

class DSV
  QUOTE_MODES = {
    unspecified: :unspecified,
    unquoted: :unquoted, none: :unquoted,
    double: :double, double_quoted: :double, double_quotes: :double,
    single: :single, single_quoted: :single, single_quotes: :single,
    spacey_unquoted: :spacey_unquoted, spacey_none: :spacey_unquoted,
    spacey_double: :spacey_double,
    spacey_single: :spacey_single
  }

  class << self
    def extract_options(args)
      args.last.is_a?(::Hash) ? args.pop : {}
    end

    def normalised_mode(mode)
      case mode.to_s
      when 'r', 'r+', 'w', 'w+', 'a', 'a+'; mode.to_s
      when 'read_only', 'read-only', 'readonly'; 'r'
      when 'rw', 'read_write', 'read-write', 'readwrite'; 'r+'
      when 'write_only', 'write-only', 'writeonly'; 'w'
      when 'append'; 'a'
      else 'r'
      end
    end

    def source_type(source, mode = nil)
      if ['w', 'w+', 'a', 'a+'].include?(normalised_mode(mode)) || ::File.exist?(source)
        DSV::File
      else
        DSV::String
      end
    end

    def open(source, *args, &block)
      csv_file = new(source, *args)
      if block
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
      return to_enum(:each, source, *args) unless block
      options = DSV.extract_options(args)
      opened(source, options){|dsv| dsv.each(*args, &block)}
    end
    alias_method :foreach, :each

    def collect(source, *args, &block)
      each(source, *args).collect(&block)
    end
    alias_method :map, :collect

    def select(source, *args, &block)
      each(source, *args).select(&block)
    end
    alias_method :find_all, :select
    alias_method :filter, :select

    def reject(source, *args, &block)
      each(source, *args).reject(&block)
    end

    def detect(source, *args, &block)
      each(source, *args).detect(&block)
    end
    alias_method :find, :detect

    def read(source, *args, &block)
      if block
        parse(source, *args, &block)
      else
        options = DSV.extract_options(args)
        opened(source, options){|dsv| dsv.read_csv(*args)}
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
      opened(source, *args, &:write_csv)
    end
    alias_method :write_csv, :write

    def header_row(source, *args)
      opened(source, *args, &:attributes)
    end

    def first_row(source, *args)
      opened(source, *args, &:first_row)
    end

    def attributes(source, *args)
      opened(source, *args, &:attributes)
    end

    def columns(source, *args)
      opened(source, *args, &:columns)
    end

    def parse_line(raw_row, *args)
      options = DSV.extract_options(args)
      row_separator = options[:row_separator] || options[:row_sep] || "\n"
      column_separator = options[:column_separator] || options[:col_sep] || ','
      sc = DSV.new(raw_row, quote: options[:quote], as_array: true, row_separator: row_separator, column_separator: column_separator)
      sc.parse_row(raw_row)
    end

    private

    def opened(source, *args)
      dsv = new(source, *args)
      yield dsv
    ensure
      dsv.close if dsv && source.is_a?(::String)
    end
  end # class << self

  include Enumerable

  attr_accessor :header_row, :mode, :row_separator, :selected_columns, :as_array, :rows
  attr_reader :quote

  def quote=(quote)
    @quote = QUOTE_MODES[quote&.to_sym] || :unspecified
    @read_separator = spacey? ? spaced(@column_separator) : @column_separator
    @quoted_separators = nil
    @read_row = row_reader
    @render_row = nil
  end

  def close
    @source.close
  end

  def read(*selected_columns, &block)
    selected_columns = selection(selected_columns).flatten
    if block
      parse(*selected_columns, &block)
    else
      read_header
      @rows = []
      @source.each(@row_separator){|raw_row| @rows << parse_fields(row_fields(raw_row), *selected_columns)}
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
    return @columns if defined?(@columns)
    @columns = (
      if header_row? && ['r', 'r+', 'a+'].include?(@mode) && (first_row = first_row?)
        columns, i = {}, -1
        (split_row(first_row) || raise(UnterminatedQuote.new(1))).each do |column_name|
          columns[column_name] = columns.key?(column_name) ? [*columns[column_name], i += 1] : (i += 1)
        end
        columns
      else
        nil
      end
    )
  rescue UnexpectedRow => error
    error.line = 1
    raise
  end

  def columns=(*column_order)
    @columns = {}
    @attributes = @repeated_names = nil
    column_order.flatten!
    if column_order[0].is_a?(Hash)
      column_order[0].each{|column_name, column_position| @columns[column_name.to_s] = column_position}
    else
      i = -1
      column_order.each{|column| @columns[column.to_s] = @columns.key?(column.to_s) ? [*@columns[column.to_s], i += 1] : (i += 1)}
    end
  end

  def repeated_names
    @repeated_names ||= (columns || {}).select{|name, position| position.is_a?(::Array)}.keys
  end

  def parse_row(raw_row, *selected_columns)
    parse_fields(split_row(raw_row) || raise(UnterminatedQuote.new(1)), *selected_columns.flatten)
  rescue UnexpectedRow => error
    error.line = 1
    raise
  end

  def write(*selected_columns)
    selected_columns.flatten!
    prepare_to_rewrite if @mode == 'r+'
    self.columns = @rows[0].flat_map{|name, value| value.is_a?(::Array) ? ::Array.new(value.size, name) : name} if blank?(columns) && @rows[0].is_a?(::Hash) && @rows[0].keys[0].is_a?(::String)
    write_header(*selected_columns) if header_row? && attributes && writes_header?
    each{|row| write_row(row, *selected_columns)}
  end
  alias_method :write_csv, :write

  def write_header(*selected_columns)
    selected_columns.flatten!
    names = selected_columns.empty? ? attributes : selected_columns
    write_values(names)
  end
  alias_method :write_csv_header, :write_header

  def write_row(row, *selected_columns)
    selected_columns.flatten!
    values = (
      if !selected_columns.empty?
        selected_columns.collect{|column| row[column]}
      elsif attributes
        values_in_order(row)
      else
        row.values
      end
    )
    write_values(values)
  end
  alias_method :write_csv_row, :write_row

  def each(*selected_columns)
    return to_enum(:each, *selected_columns) unless block_given?
    selected_columns = selection(selected_columns)
    selected_columns.flatten!
    if @rows[0]
      if selected_columns.empty?
        @rows.each{|row| yield row}
      elsif @as_array
        @rows.each{|row| yield row.values_at(*positions(selected_columns))}
      else
        @rows.each do |row|
          yield selected_columns.inject({}){|hash, column_name| hash[column_name] = row[column_name]; hash}
        end
      end
    else
      if selected_columns.empty? || @as_array
        read_csv(*selected_columns).each{|row| yield row}
      else
        read_csv(*selected_columns).each do |row|
          yield selected_columns.inject({}){|hash, column_name| hash[column_name] = row[column_name]; hash}
        end
      end
    end
  end
  alias_method :each_row, :each

  def attributes
    @attributes ||= (
      if blank?(columns)
        nil
      else
        a = []
        columns.each do |k,v|
          case v
          when Array
            v.each{|e| a << [k, e]}
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
    elsif blank?(@columns)
      @rows.collect(&:values)
    else
      @rows.collect{|row| values_in_order(row)}
    end
  end

  private

  def initialize(source, *args)
    options = DSV.extract_options(args)
    @source = (
      if source.is_a?(::String)
        DSV.source_type(source, options[:mode]).source(source, options)
      else
        source
      end
    )
    @header_row = options[:header_row] || options[:headers] || options[:header] || false
    @mode = DSV.normalised_mode(options[:mode])
    @row_separator = options[:row_separator] || options[:row_sep] || "\n"
    @column_separator = options[:column_separator] || options[:col_sep] || ','
    self.quote = options[:quote]
    @selected_columns = options[:selected_columns]
    @as_array = options[:as_array] || false
    if options[:columns]
      self.columns = options[:columns]
    else
      self.columns
    end
    @rows = []
  end

  def selection(selected_columns)
    selected_columns.empty? ? Array(@selected_columns) : selected_columns
  end

  def store_field(parsed_row, name, value)
    if repeated_names.include?(name)
      (parsed_row[name] ||= []) << value
    else
      parsed_row[name] = value
    end
  end

  def values_in_order(row)
    return row.values_at(*attributes) if repeated_names.empty?
    occurrence = ::Hash.new(0)
    attributes.collect do |name|
      value = row[name]
      value = value[occurrence[name]] if value.is_a?(::Array) && repeated_names.include?(name)
      occurrence[name] += 1
      value
    end
  end

  def blank?(value)
    value.nil? || value.empty?
  end

  def split_row(raw_row)
    @read_row.call(raw_row.chomp(@row_separator))
  end

  def row_reader
    case @quote
    when :unquoted, :spacey_unquoted; ->(row){split_on(row, @read_separator)}
    when :double, :spacey_double; ->(row){split_wholly_quoted(row, '"')}
    when :single, :spacey_single; ->(row){split_wholly_quoted(row, "'")}
    else ->(row){split_quoted(row)}
    end
  end

  def spacey?
    @quote.start_with?('spacey_')
  end

  def spaced(separator)
    if separator.is_a?(::Regexp)
      ::Regexp.new('(?:' + separator.source + ') ', separator.options)
    else
      separator + ' '
    end
  end

  def split_on(row, separator)
    case separator
    when ::Regexp; pieces_and_separators(row, separator).first
    when ' '; row.split(/ /, -1)
    else row.split(separator, -1)
    end
  end

  def pieces_and_separators(row, separator)
    pieces, separators, position = [], [], 0
    row.scan(separator) do
      match = ::Regexp.last_match
      pieces << row[position...match.begin(0)]
      separators << match[0]
      position = match.end(0)
    end
    [pieces << row[position..], separators]
  end

  def split_quoted(row)
    if @read_separator.is_a?(::Regexp)
      reassemble_quoted_fields(*pieces_and_separators(row, @read_separator))
    else
      reassemble_quoted_fields(split_on(row, @read_separator))
    end
  end

  def split_wholly_quoted(row, quote)
    raise UnquotedField.new(@quote) unless row.start_with?(quote)
    fields = split_on(row.delete_prefix(quote), quoted_separator(quote))
    return reassemble_wholly_quoted_fields(row, quote) unless fields.last && trailing_quotes(fields.last, -1, quote.getbyte(0)).odd?
    fields[-1] = fields.last.delete_suffix(quote)
    unescaped_fields(fields, quote) || reassemble_wholly_quoted_fields(row, quote)
  end

  def reassemble_wholly_quoted_fields(row, quote)
    pieces, separators = (
      if @read_separator.is_a?(::Regexp)
        pieces_and_separators(row, @read_separator)
      else
        [split_on(row, @read_separator), nil]
      end
    )
    fields = []
    buffer = nil
    quote_byte, escaped = quote.getbyte(0), quote * 2
    pieces.each_with_index do |piece, i|
      if buffer && trailing_quotes(piece, -1, quote_byte).even?
        buffer << separator_before(i, separators) << piece
      elsif buffer
        fields << (buffer << separator_before(i, separators) << piece.delete_suffix(quote)).gsub(escaped, quote)
        buffer = nil
      elsif !piece.start_with?(quote)
        raise UnquotedField.new(@quote)
      elsif trailing_quotes(piece, 0, quote_byte).even?
        buffer = +piece.delete_prefix(quote)
      else
        fields << piece.delete_prefix(quote).delete_suffix(quote).gsub(escaped, quote)
      end
    end
    fields unless buffer
  end

  def unescaped_fields(fields, quote)
    escaped = quote * 2
    fields.collect do |field|
      next field unless field.include?(quote)
      unescaped = field.gsub(escaped, quote)
      return nil unless field.count(quote) == 2 * unescaped.count(quote)
      unescaped
    end
  end

  def quoted_separator(quote)
    (@quoted_separators ||= {})[quote] ||= (
      if @read_separator.is_a?(::Regexp)
        ::Regexp.new(quote + '(?:' + @read_separator.source + ')' + quote, @read_separator.options)
      else
        quote + @read_separator + quote
      end
    )
  end

  def reassemble_quoted_fields(pieces, separators = nil)
    fields = []
    buffer = nil
    pieces.each_with_index do |piece, i|
      if buffer && trailing_quotes(piece, -1).even?
        buffer << separator_before(i, separators) << piece
      elsif buffer
        fields << (buffer << separator_before(i, separators) << piece.delete_suffix('"')).gsub('""', '"')
        buffer = nil
      elsif piece.start_with?('"') && trailing_quotes(piece, 0).even?
        buffer = +piece.delete_prefix('"')
      elsif piece.start_with?('"')
        fields << piece.delete_prefix('"').delete_suffix('"').gsub('""', '"')
      else
        fields << piece
      end
    end
    fields unless buffer
  end

  def trailing_quotes(piece, floor, quote_byte = 34)
    i = piece.bytesize - 1
    i -= 1 while i > floor && piece.getbyte(i) == quote_byte
    piece.bytesize - 1 - i
  end

  def separator_before(i, separators)
    separators ? separators[i - 1] : @read_separator
  end

  def row_fields(raw_row)
    raw_row << @source.gets(@row_separator) until (fields = split_row(raw_row)) || @source.eof?
    fields || raise(UnterminatedQuote.new(line_of(raw_row)))
  rescue UnexpectedRow => error
    error.line = line_of(raw_row)
    raise
  end

  def line_of(raw_row)
    start = @source.pos - raw_row.bytesize
    @source.rewind
    @source.read(start).to_s.scan(@row_separator).length + 1
  end

  def parse_fields(fields, *selected_columns)
    return fields.values_at(*positions(selected_columns)) if @as_array && !selected_columns.empty?
    parsed_row = {}
    i = -1
    if selected_columns.empty?
      if blank?(@columns)
        fields.each{|column_value| parsed_row[i += 1] = column_value}
      elsif repeated_names.empty?
        fields.each{|column_value| parsed_row[attributes[i += 1]] = column_value}
      else
        fields.each{|column_value| store_field(parsed_row, attributes[i += 1], column_value)}
      end
    else
      case selected_columns[0]
      when Integer
        fields.each{|column_value| parsed_row[i] = column_value unless !selected_columns.include?(i += 1)}
      else
        if repeated_names.empty?
          fields.each{|column_value| parsed_row[attributes[i]] = column_value unless !selected_columns.include?(attributes[i += 1])}
        else
          fields.each{|column_value| store_field(parsed_row, attributes[i], column_value) unless !selected_columns.include?(attributes[i += 1])}
        end
      end
    end
    if @as_array
      if blank?(@columns)
        (0..(parsed_row.size - 1)).inject([]){|a,i| a << parsed_row[i]}
      else
        values_in_order(parsed_row)
      end
    else
      parsed_row
    end
  end

  def positions(selected_columns)
    selected_columns.flat_map{|column| column.is_a?(::Integer) ? column : Array((columns || {})[column])}.sort
  end

  def prepare_to_rewrite
    read_csv unless @rows[0]
    @source.rewind
    @source.truncate(0)
  end

  def writes_header?
    return true unless ['a', 'a+'].include?(@mode) && @source.respond_to?(:size)
    @source.size.zero?
  end

  def write_values(values)
    @render_row ||= row_renderer
    @source.write(@render_row.call(values))
  end

  def writable_column_separator
    raise ::ArgumentError, "a Regexp column separator can be read with, not written with; give a String to write" if @column_separator.is_a?(::Regexp)
    @column_separator
  end

  def row_renderer
    separator = spacey? ? spaced(writable_column_separator) : writable_column_separator
    case @quote
    when :unquoted, :spacey_unquoted; unquoted_row_renderer(separator)
    when :single, :spacey_single; quoted_row_renderer("'", separator)
    else quoted_row_renderer('"', separator)
    end
  end

  def quoted_row_renderer(quote, separator)
    doubled_quote = quote * 2
    ->(values){values.collect{|value| quote + value.to_s.gsub(quote, doubled_quote) + quote}.join(separator) + @row_separator}
  end

  def unquoted_row_renderer(separator)
    ->(values){values.join(separator) + @row_separator}
  end
end # class DSV
