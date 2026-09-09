# SimpleCSV_test.rb

# 20260908, 09

# A specification of SimpleCSV's interface: what it does today and should go on
# doing, and what it should do and does not yet.  The second kind is skipped, the
# skip message naming the finding in the Handoff 0 closing note
# (dsv/closing-note.md) or the observation that it answers, so that the skip
# count is the fault list and each fix is one skip removed.
#
# Four findings have no example, since each waits on a decision that the test
# would prejudge: 5 (duplicate header names, Decision point 6), 9 (header_row as
# a class method, Decision point 9), 12 (selected_columns:, Decision point 8) and
# 17 (writing with no columns defined, Decision point 7).  An example whose skip
# message names a decision point states the option the closing note leans to
# and is provisional until the decision is recorded.
#
# The RFC 4180 cases are taken from stdlib CSV's parsing tests, rewritten here.
# One convention differs from CSV throughout: an empty field reads as "" rather
# than nil, as it does in SimpleCSV today.  Whether that stays is part of the
# open question of surface compatibility with CSV.

require 'minitest/autorun'
require 'minitest/mock'
require 'stringio'
require 'tmpdir'

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'SimpleCSV'

DATA = "a,b,c\n1,2,3\n4,5,6\n"
KEYED = [{'a' => '1', 'b' => '2', 'c' => '3'}, {'a' => '4', 'b' => '5', 'c' => '6'}]
POSITIONAL = [{0 => '1', 1 => '2', 2 => '3'}, {0 => '4', 1 => '5', 2 => '6'}]
ARRAYS = [['1', '2', '3'], ['4', '5', '6']]

describe SimpleCSV do
  # A writer over a StringIO, returning what was written.
  def written(*arguments)
    io = StringIO.new
    csv = SimpleCSV.new(io, *arguments)
    yield csv
    io.string
  end

  # The rows a block-taking class method yields.
  def yielded(method, *arguments)
    rows = []
    SimpleCSV.send(method, *arguments){|row| rows << row}
    rows
  end

  # A temporary file holding DATA, given to the block by path.
  def with_file(contents = DATA)
    Dir.mktmpdir('SimpleCSV') do |directory|
      path = File.join(directory, 'data.csv')
      File.write(path, contents)
      yield path, directory
    end
  end

  # How many times a class's new is called while the block runs.
  def constructions(klass)
    count = 0
    original = klass.method(:new)
    klass.stub(:new, ->(*arguments, &block){count += 1; original.call(*arguments, &block)}){yield}
    count
  end

  describe ".read" do
    it "reads rows keyed by position when there is no header row" do
      _(SimpleCSV.read("1,2,3\n4,5,6\n")).must_equal POSITIONAL
    end

    it "reads rows keyed by column name when headers: is true" do
      _(SimpleCSV.read(DATA, headers: true)).must_equal KEYED
    end

    it "accepts header_row: and header: as spellings of headers:" do
      _(SimpleCSV.read(DATA, header_row: true)).must_equal KEYED
      _(SimpleCSV.read(DATA, header: true)).must_equal KEYED
    end

    it "keys by string, so header names are strings" do
      _(SimpleCSV.read(DATA, headers: true).first.keys).must_equal ['a', 'b', 'c']
    end

    it "reads rows as arrays when as_array: is true" do
      _(SimpleCSV.read(DATA, headers: true, as_array: true)).must_equal ARRAYS
      _(SimpleCSV.read("1,2,3\n4,5,6\n", as_array: true)).must_equal ARRAYS
    end

    it "names the columns of a headerless source from columns: given as an array" do
      _(SimpleCSV.read("1,2,3\n4,5,6\n", columns: [:x, :y, :z])).must_equal [{'x' => '1', 'y' => '2', 'z' => '3'}, {'x' => '4', 'y' => '5', 'z' => '6'}]
    end

    it "maps names to positions from columns: given as a hash" do
      rows = SimpleCSV.read("1,2,3\n4,5,6\n", columns: {x: 0, z: 2})
      _(rows.map{|row| row.values_at('x', 'z')}).must_equal [['1', '2'], ['4', '5']]
    end

    it "reads an empty source as no rows" do
      _(SimpleCSV.read('', headers: true)).must_equal []
    end

    it "yields each row instead of returning them when given a block" do
      _(yielded(:read, DATA, headers: true)).must_equal KEYED
    end

    it "is aliased read_csv" do
      _(SimpleCSV.read_csv(DATA, headers: true)).must_equal KEYED
    end

    it "selects columns given as arguments, as #read does" do
      skip "Finding 7: the class method discards the selection"
      _(SimpleCSV.read(DATA, 'a', headers: true)).must_equal [{'a' => '1'}, {'a' => '4'}]
      _(SimpleCSV.read(DATA, ['a', 'c'], headers: true)).must_equal [{'a' => '1', 'c' => '3'}, {'a' => '4', 'c' => '6'}]
    end
  end

  describe ".parse" do
    it "reads like .read without a block" do
      _(SimpleCSV.parse(DATA, headers: true)).must_equal KEYED
    end

    it "yields each row with a block" do
      _(yielded(:parse, DATA, headers: true)).must_equal KEYED
    end

    it "is aliased parse_csv" do
      _(SimpleCSV.parse_csv(DATA, headers: true)).must_equal KEYED
    end
  end

  describe ".each" do
    it "yields each row" do
      _(yielded(:each, DATA, headers: true)).must_equal KEYED
    end

    it "returns the rows" do
      _(SimpleCSV.each(DATA, headers: true){|row| }).must_equal KEYED
    end

    it "is aliased foreach" do
      _(yielded(:foreach, DATA, headers: true)).must_equal KEYED
    end
  end

  describe ".collect, .select, .reject and .detect" do
    it "collects the block value for each row, also as map" do
      _(SimpleCSV.collect(DATA, headers: true){|row| row['a'].to_i}).must_equal [1, 4]
      _(SimpleCSV.map(DATA, headers: true){|row| row['a'].to_i}).must_equal [1, 4]
    end

    it "selects the rows for which the block is true, also as find_all" do
      _(SimpleCSV.select(DATA, headers: true){|row| row['a'] == '4'}).must_equal [KEYED.last]
      _(SimpleCSV.find_all(DATA, headers: true){|row| row['a'] == '4'}).must_equal [KEYED.last]
    end

    it "rejects the rows for which the block is true" do
      _(SimpleCSV.reject(DATA, headers: true){|row| row['a'] == '4'}).must_equal [KEYED.first]
    end

    it "detects the first row for which the block is true, also as find" do
      _(SimpleCSV.detect(DATA, headers: true){|row| row['a'] == '4'}).must_equal KEYED.last
      _(SimpleCSV.find(DATA, headers: true){|row| row['a'] == '4'}).must_equal KEYED.last
    end

    it "detects nil when no row matches" do
      skip "Finding 8: the fall-through returns every row"
      _(SimpleCSV.detect(DATA, headers: true){|row| false}).must_be_nil
    end
  end

  describe ".first_row, .attributes and .columns" do
    it "first_row returns the first line, separator included" do
      _(SimpleCSV.first_row(DATA, headers: true)).must_equal "a,b,c\n"
    end

    it "attributes returns the column names in order, or nil without a header row" do
      _(SimpleCSV.attributes(DATA, headers: true)).must_equal ['a', 'b', 'c']
      _(SimpleCSV.attributes(DATA)).must_be_nil
    end

    it "columns returns the column names mapped to positions, or nil without a header row" do
      _(SimpleCSV.columns(DATA, headers: true)).must_equal({'a' => 0, 'b' => 1, 'c' => 2})
      _(SimpleCSV.columns(DATA)).must_be_nil
    end
  end

  describe ".parse_line" do
    it "splits one line into an array of fields" do
      _(SimpleCSV.parse_line("1,2,3\n")).must_equal ['1', '2', '3']
    end

    it "strips quotes from quoted fields" do
      _(SimpleCSV.parse_line("\"1\",\"2\"\n")).must_equal ['1', '2']
    end

    it "takes col_sep: and row_sep:" do
      _(SimpleCSV.parse_line("1\t2\t3\n", col_sep: "\t")).must_equal ['1', '2', '3']
      _(SimpleCSV.parse_line("1,2,3\r\n", row_sep: "\r\n")).must_equal ['1', '2', '3']
    end

    it "leaves the caller's string as it was" do
      skip "Finding 13: split_csv chomps the receiver in place"
      line = "1,2,3\n"
      SimpleCSV.parse_line(line)
      _(line).must_equal "1,2,3\n"
    end
  end

  describe "parsing per RFC 4180" do
    it "reads unquoted fields, quoted fields, an empty quoted field and a lone field" do
      _(SimpleCSV.parse_line("\t")).must_equal ["\t"]
      _(SimpleCSV.parse_line('foo')).must_equal ['foo']
      _(SimpleCSV.parse_line('""')).must_equal ['']
      _(SimpleCSV.parse_line('foo,"",baz')).must_equal ['foo', '', 'baz']
      _(SimpleCSV.parse_line('"1997","Ford","E350"')).must_equal ['1997', 'Ford', 'E350']
    end

    it "keeps spaces around a field, since they are part of it" do
      _(SimpleCSV.parse_line('1997, Ford , E350')).must_equal ['1997', ' Ford ', ' E350']
      _(SimpleCSV.parse_line('1997,Ford,E350," Super luxurious truck "')).must_equal ['1997', 'Ford', 'E350', ' Super luxurious truck ']
    end

    it "reads an empty field between or before others as an empty string" do
      _(SimpleCSV.parse_line('foo,,baz')).must_equal ['foo', '', 'baz']
      _(SimpleCSV.parse_line(',foo,bar')).must_equal ['', 'foo', 'bar']
    end

    it "reads a separator inside a quoted field" do
      _(SimpleCSV.parse_line('"a, b",c')).must_equal ['a, b', 'c']
    end

    it "reads a line break inside a quoted field of one line" do
      _(SimpleCSV.parse_line("foo,\"\r\n\",baz")).must_equal ['foo', "\r\n", 'baz']
      _(SimpleCSV.parse_line("foo,\"\n\",baz")).must_equal ['foo', "\n", 'baz']
    end

    it "reads a doubled quote inside a quoted field as one quote" do
      skip "Finding 1: doubled quotes are not unescaped"
      _(SimpleCSV.parse_line('"say ""hi""",2')).must_equal ['say "hi"', '2']
      _(SimpleCSV.parse_line('foo,"""bar""",baz')).must_equal ['foo', '"bar"', 'baz']
      _(SimpleCSV.parse_line('foo,"""",baz')).must_equal ['foo', '"', 'baz']
      _(SimpleCSV.parse_line('foo,"""""",baz')).must_equal ['foo', '""', 'baz']
    end

    it "reads a trailing empty field as an empty string" do
      skip "Finding 2: a trailing empty field is dropped"
      _(SimpleCSV.parse_line('foo,bar,')).must_equal ['foo', 'bar', '']
      _(SimpleCSV.parse_line(',')).must_equal ['', '']
      _(SimpleCSV.parse_line(',,')).must_equal ['', '', '']
    end

    it "reads more than one separator inside a quoted field, and a field that is only a separator" do
      skip "Finding 3: the pieces are reassembled without the separator between the middle ones"
      _(SimpleCSV.parse_line('"a, b, c",d')).must_equal ['a, b, c', 'd']
      _(SimpleCSV.parse_line('","')).must_equal [',']
      _(SimpleCSV.parse_line('",",","')).must_equal [',', ',']
    end

    it "reads a quoted field holding the row separator as one field across lines" do
      skip "Decision point 5: the source is read line by line; a replacement parser would carry a quoted field across the separator"
      _(SimpleCSV.read("a,b\n\"x\ny\",2\n", headers: true)).must_equal [{'a' => "x\ny", 'b' => '2'}]
    end
  end

  describe ".open" do
    it "returns an instance without a block" do
      csv = SimpleCSV.open(DATA, headers: true)
      _(csv).must_be_instance_of SimpleCSV
      _(csv.read).must_equal KEYED
    end

    it "yields the instance, closes it and returns it with a block" do
      given = nil
      returned = SimpleCSV.open(DATA, headers: true){|csv| given = csv}
      _(returned).must_be_same_as given
      _(given.instance_variable_get(:@source).closed?).must_equal true
    end

    it "keeps no instance in the class between calls" do
      skip "Finding 22: the instance is kept in SimpleCSV's own @csv_file"
      SimpleCSV.open(DATA)
      _(SimpleCSV.instance_variable_defined?(:@csv_file)).must_equal false
    end
  end

  describe ".source_type" do
    it "is SimpleCSV::File for the path of an existing file and SimpleCSV::String for text" do
      with_file{|path| _(SimpleCSV.source_type(path)).must_equal SimpleCSV::File}
      _(SimpleCSV.source_type(DATA)).must_equal SimpleCSV::String
    end
  end

  describe ".new" do
    it "takes an IO as the source directly" do
      _(SimpleCSV.new(StringIO.new(DATA), headers: true).read).must_equal KEYED
    end

    it "exposes the options as accessors, quote defaulting to nil" do
      csv = SimpleCSV.new(DATA, headers: true, mode: 'r', quote: :none, row_separator: "\n", as_array: false)
      _(csv.header_row).must_equal true
      _(csv.header_row?).must_equal true
      _(csv.mode).must_equal 'r'
      _(csv.quote).must_equal :none
      _(csv.row_separator).must_equal "\n"
      _(csv.as_array).must_equal false
      _(SimpleCSV.new(DATA).header_row?).must_equal false
      _(SimpleCSV.new(DATA).quote).must_be_nil
    end

    it "reads the header row under mode: given as a symbol or a long name" do
      skip "Finding 6: columns tests the mode as given against the literal strings r, r+ and a+"
      _(SimpleCSV.new(DATA, headers: true, mode: :r).read).must_equal KEYED
      with_file{|path| _(SimpleCSV.new(path, headers: true, mode: :read_only).read).must_equal KEYED}
      with_file{|path| _(SimpleCSV.new(path, headers: true, mode: 'rw').read).must_equal KEYED}
    end
  end

  describe "#read" do
    it "returns the rows and keeps them in rows" do
      csv = SimpleCSV.new(DATA, headers: true)
      _(csv.rows).must_equal []
      _(csv.read).must_equal KEYED
      _(csv.rows).must_equal KEYED
    end

    it "selects columns by name, given singly or as an array" do
      _(SimpleCSV.new(DATA, headers: true).read('a')).must_equal [{'a' => '1'}, {'a' => '4'}]
      _(SimpleCSV.new(DATA, headers: true).read('a', 'c')).must_equal [{'a' => '1', 'c' => '3'}, {'a' => '4', 'c' => '6'}]
      _(SimpleCSV.new(DATA, headers: true).read(['a', 'c'])).must_equal [{'a' => '1', 'c' => '3'}, {'a' => '4', 'c' => '6'}]
    end

    it "selects columns by position, keyed by position even under a header row" do
      _(SimpleCSV.new("1,2,3\n4,5,6\n").read(0, 2)).must_equal [{0 => '1', 2 => '3'}, {0 => '4', 2 => '6'}]
      _(SimpleCSV.new(DATA, headers: true).read(0, 2)).must_equal [{0 => '1', 2 => '3'}, {0 => '4', 2 => '6'}]
    end

    it "yields each row with a block, as does #parse" do
      rows = []
      SimpleCSV.new(DATA, headers: true).read{|row| rows << row}
      _(rows).must_equal KEYED
      _(SimpleCSV.new(DATA, headers: true).parse).must_equal KEYED
    end

    it "gives a short row only the columns it has" do
      _(SimpleCSV.read("a,b,c\n1,2\n", headers: true)).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "returns the same rows when read again" do
      skip "Observation: a second read appends the rows again"
      csv = SimpleCSV.new(DATA, headers: true)
      csv.read
      _(csv.read).must_equal KEYED
    end
  end

  describe "#each" do
    it "yields each row, reading the source first if it has not been read" do
      rows = []
      SimpleCSV.new(DATA, headers: true).each{|row| rows << row}
      _(rows).must_equal KEYED
    end

    it "yields only the selected columns, before or after a read" do
      rows = []
      SimpleCSV.new(DATA, headers: true).each('a'){|row| rows << row}
      _(rows).must_equal [{'a' => '1'}, {'a' => '4'}]
      csv = SimpleCSV.new(DATA, headers: true)
      csv.read
      rows = []
      csv.each('a', 'c'){|row| rows << row}
      _(rows).must_equal [{'a' => '1', 'c' => '3'}, {'a' => '4', 'c' => '6'}]
    end

    it "is aliased each_row and backs Enumerable" do
      _(SimpleCSV.include?(Enumerable)).must_equal true
      _(SimpleCSV.new(DATA, headers: true).map{|row| row['a']}).must_equal ['1', '4']
      _(SimpleCSV.new(DATA, headers: true).count).must_equal 2
      _(SimpleCSV.new(DATA, headers: true).first).must_equal KEYED.first
    end

    it "returns an enumerator without a block" do
      skip "Finding 11: each yields unconditionally and raises LocalJumpError"
      _(SimpleCSV.new(DATA, headers: true).each).must_be_kind_of Enumerator
      _(SimpleCSV.new(DATA, headers: true).each.to_a).must_equal KEYED
      _(SimpleCSV.new(DATA, headers: true).each('a').to_a).must_equal [{'a' => '1'}, {'a' => '4'}]
    end
  end

  describe "#to_a" do
    it "returns the rows as arrays in column order" do
      _(SimpleCSV.new(DATA, headers: true).to_a).must_equal ARRAYS
    end

    it "returns rows as read when as_array: is true" do
      _(SimpleCSV.new(DATA, headers: true, as_array: true).to_a).must_equal ARRAYS
    end

    it "returns the rows as arrays in position order when there are no columns" do
      skip "Finding 10: the positional branch builds an array and discards it"
      _(SimpleCSV.new("1,2\n3,4\n").to_a).must_equal [['1', '2'], ['3', '4']]
    end
  end

  describe "#columns= and #attributes=" do
    it "columns= takes names in order, or a hash of name to position, as strings" do
      csv = SimpleCSV.new("1,2\n")
      csv.columns = [:p, :q]
      _(csv.columns).must_equal({'p' => 0, 'q' => 1})
      _(csv.attributes).must_equal ['p', 'q']
      _(csv.read).must_equal [{'p' => '1', 'q' => '2'}]
      csv = SimpleCSV.new("1,2\n")
      csv.columns = {p: 0, q: 1}
      _(csv.columns).must_equal({'p' => 0, 'q' => 1})
    end

    it "attributes= sets the names without setting columns, so rows stay positional" do
      csv = SimpleCSV.new("1,2\n")
      csv.attributes = ['p', 'q']
      _(csv.attributes).must_equal ['p', 'q']
      _(csv.columns).must_be_nil
      _(csv.read).must_equal [{0 => '1', 1 => '2'}]
    end
  end

  describe "column separators on read" do
    it "reads a tab, given as column_separator: or col_sep:" do
      _(SimpleCSV.read("a\tb\n1\t2\n", headers: true, column_separator: "\t")).must_equal [{'a' => '1', 'b' => '2'}]
      _(SimpleCSV.read("a\tb\n1\t2\n", headers: true, col_sep: "\t")).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "reads a pipe and a semicolon" do
      _(SimpleCSV.read("a|b\n1|2\n", headers: true, column_separator: '|')).must_equal [{'a' => '1', 'b' => '2'}]
      _(SimpleCSV.read("a;b\n1;2\n", headers: true, column_separator: ';')).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "reads a multi-character separator" do
      _(SimpleCSV.read("a::b\n1::2\n", headers: true, column_separator: '::')).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "reads a regular expression separator" do
      _(SimpleCSV.read("a, b\n1,2\n", headers: true, column_separator: /,\s*/)).must_equal [{'a' => '1', 'b' => '2'}]
    end
  end

  describe "row separators on read" do
    it "reads CRLF, given as row_separator: or row_sep:, and by default" do
      _(SimpleCSV.read("a,b\r\n1,2\r\n", headers: true, row_separator: "\r\n")).must_equal [{'a' => '1', 'b' => '2'}]
      _(SimpleCSV.read("a,b\r\n1,2\r\n", headers: true, row_sep: "\r\n")).must_equal [{'a' => '1', 'b' => '2'}]
      _(SimpleCSV.read("a,b\r\n1,2\r\n", headers: true)).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "reads any other row separator" do
      _(SimpleCSV.read('a,b|1,2|', headers: true, row_separator: '|')).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "reads a blank line as an empty row" do
      _(SimpleCSV.read("a,b\n\n1,2\n", headers: true)).must_equal [{}, {'a' => '1', 'b' => '2'}]
    end
  end

  describe "quoting on read" do
    it "strips quotes from quoted fields and headers by default" do
      _(SimpleCSV.read("a,b\n\"x\",\"2\"\n", headers: true)).must_equal [{'a' => 'x', 'b' => '2'}]
      _(SimpleCSV.read("\"a\",\"b\"\n1,2\n", headers: true)).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "keeps a separator inside a quoted field by default" do
      _(SimpleCSV.read("a,b\n\"x, y\",2\n", headers: true)).must_equal [{'a' => 'x, y', 'b' => '2'}]
    end

    it "keeps the quotes under quote: :none" do
      _(SimpleCSV.read("a,b\n\"x\",\"2\"\n", headers: true, quote: :none)).must_equal [{'a' => '"x"', 'b' => '"2"'}]
    end

    it "strips the quotes under quote: :double" do
      _(SimpleCSV.read("a,b\n\"x\",\"2\"\n", headers: true, quote: :double)).must_equal [{'a' => 'x', 'b' => '2'}]
    end

    it "gathers empty header names into one array-valued column" do
      _(SimpleCSV.columns(",,b\n1,2,3\n", headers: true)).must_equal({'' => [0, 1], 'b' => 2})
      _(SimpleCSV.attributes(",,b\n1,2,3\n", headers: true)).must_equal ['', '', 'b']
    end

    it "reads a doubled quote as one quote in a row" do
      skip "Finding 1: doubled quotes are not unescaped"
      _(SimpleCSV.read("a,b\n\"say \"\"hi\"\"\",2\n", headers: true)).must_equal [{'a' => 'say "hi"', 'b' => '2'}]
    end

    it "reads a trailing empty field as an empty string under its column" do
      skip "Finding 2: a trailing empty field is dropped"
      _(SimpleCSV.read("a,b,c\n1,2,\n", headers: true)).must_equal [{'a' => '1', 'b' => '2', 'c' => ''}]
      _(SimpleCSV.read("1,2,\n")).must_equal [{0 => '1', 1 => '2', 2 => ''}]
    end

    it "keeps every separator inside a quoted field in a row" do
      skip "Finding 3: the second of two separators is lost"
      _(SimpleCSV.read("\"x, y, z\",2\n")).must_equal [{0 => 'x, y, z', 1 => '2'}]
    end

    it "keeps a separator inside a quoted field under quote: :double" do
      skip "Decision point 5: Finding 4, if the :double mode survives; that path strips quotes after splitting"
      _(SimpleCSV.read("a,b\n\"x, y\",\"2\"\n", headers: true, quote: :double)).must_equal [{'a' => 'x, y', 'b' => '2'}]
    end
  end

  describe "#write" do
    it "writes each row in column order, double-quoted by default" do
      output = written(columns: [:a, :b]){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}
      _(output).must_equal "\"1\",\"2\"\n"
    end

    it "writes the header row first when headers: is true, and is aliased write_csv" do
      output = written(headers: true, columns: [:a, :b]){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write_csv}
      _(output).must_equal "\"a\",\"b\"\n\"1\",\"2\"\n"
    end

    it "writes unquoted under quote: :none, :unquoted or the string none, and single-quoted under :single" do
      _(written(headers: true, columns: [:a, :b], quote: :none){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}).must_equal "a,b\n1,2\n"
      _(written(columns: [:a, :b], quote: :unquoted){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}).must_equal "1,2\n"
      _(written(columns: [:a, :b], quote: 'none'){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}).must_equal "1,2\n"
      _(written(columns: [:a, :b], quote: :single){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}).must_equal "'1','2'\n"
    end

    it "writes only the selected columns" do
      output = written(columns: [:a, :b, :c]){|csv| csv.rows = [{'a' => 1, 'b' => 2, 'c' => 3}]; csv.write('a', 'c')}
      _(output).must_equal "\"1\",\"3\"\n"
    end

    it "writes what it read back, so a source round-trips" do
      output = written(headers: true, columns: [:a, :b]){|csv| csv.rows = SimpleCSV.read("a,b\n1,2\n", headers: true); csv.write}
      _(SimpleCSV.read(output, headers: true)).must_equal [{'a' => '1', 'b' => '2'}]
    end

    it "write_row and write_header write one row and the header row" do
      _(written(columns: [:a, :b]){|csv| csv.write_row('a' => 'x', 'b' => 'y')}).must_equal "\"x\",\"y\"\n"
      _(written(columns: [:a, :b]){|csv| csv.write_header}).must_equal "\"a\",\"b\"\n"
    end

    it "quotes a value holding a separator, and leaves it bare under quote: :none" do
      _(written(columns: [:a, :b]){|csv| csv.write_row('a' => 'x, y', 'b' => 'z')}).must_equal "\"x, y\",\"z\"\n"
      _(written(columns: [:a, :b], quote: :none){|csv| csv.write_row('a' => 'x, y', 'b' => 'z')}).must_equal "x, y,z\n"
    end

    it "doubles a quote inside a quoted value, per RFC 4180" do
      skip "Observation: the write side of Finding 1; an embedded quote is written once"
      _(written(columns: [:a, :b]){|csv| csv.write_row('a' => 'say "hi"', 'b' => 'z')}).must_equal "\"say \"\"hi\"\"\",\"z\"\n"
    end

    it "writes the selected column names as the header row" do
      skip "Finding 18: write_header hands columns, a Hash, to Hash#to_csv and a blank line results"
      output = written(headers: true, columns: [:a, :b, :c]){|csv| csv.rows = [{'a' => 1, 'b' => 2, 'c' => 3}]; csv.write('a', 'c')}
      _(output).must_equal "\"a\",\"c\"\n\"1\",\"3\"\n"
    end

    it "writes a nil value as an empty field, keeping the columns in place" do
      skip "Decision point 7: Finding 16, a nil value is skipped and the columns after it shift; the note takes an empty field as the obvious answer"
      output = written(columns: [:a, :b, :c]){|csv| csv.rows = [{'a' => 1, 'b' => nil, 'c' => 3}]; csv.write}
      _(output).must_equal "\"1\",\"\",\"3\"\n"
    end

    it "writes with the column and row separators given, as it reads with them" do
      skip "Finding 23: the write path joins with a literal comma and ends with puts"
      _(written(columns: [:a, :b], column_separator: "\t", quote: :none){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}).must_equal "1\t2\n"
      _(written(columns: [:a, :b], row_separator: "\r\n", quote: :none){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}).must_equal "1,2\r\n"
    end
  end

  describe "the supporting to_csv methods" do
    it "Array#to_csv writes an array of strings as one row, quoted by default and joined by comma" do
      _(['1', 'x'].to_csv).must_equal "\"1\",\"x\"\n"
      _(['1', 'x'].to_csv(:none)).must_equal "1,x\n"
      _(['1', 'x'].to_csv(:spacey_double)).must_equal "\"1\", \"x\"\n"
    end

    it "Hash#to_csv writes the selected columns' values as one row" do
      _({'a' => 1, 'b' => 2}.to_csv(selected_columns: ['b'])).must_equal "\"2\"\n"
    end

    it "Hash#to_csv writes every value as one row when no columns are selected" do
      skip "Finding 20: the loop looks each value up as a key"
      _({'a' => 1, 'b' => 2}.to_csv).must_equal "\"1\",\"2\"\n"
    end
  end

  describe "SimpleCSV::String" do
    it "reads a string, and .open behaves as SimpleCSV.open" do
      _(SimpleCSV::String.new(DATA, headers: true).read).must_equal KEYED
      _(SimpleCSV::String.open(DATA, headers: true){|csv| csv.read}).must_be_instance_of SimpleCSV::String
    end

    it ".open constructs one instance" do
      skip "Finding 19: .open constructs an instance and then super constructs another"
      _(constructions(SimpleCSV::String){SimpleCSV::String.open(DATA){|csv| }}).must_equal 1
    end
  end

  describe "SimpleCSV::File" do
    it "reads a file by path" do
      with_file{|path| _(SimpleCSV.read(path, headers: true)).must_equal KEYED}
      with_file{|path| _(SimpleCSV::File.new(path, headers: true).read).must_equal KEYED}
    end

    it "defaults the mode to r and takes permissions:" do
      with_file do |path|
        _(SimpleCSV::File.new(path).mode).must_equal 'r'
        _(SimpleCSV::File.new(path, permissions: 0644).permissions).must_equal 0644
      end
    end

    it "reads the header row under a+ and has no columns under w or w+" do
      with_file{|path| _(SimpleCSV.new(path, mode: 'a+', headers: true).columns).must_equal({'a' => 0, 'b' => 1, 'c' => 2})}
      with_file{|path| _(SimpleCSV.new(path, mode: 'w', headers: true).columns).must_be_nil}
      with_file{|path| _(SimpleCSV.new(path, mode: 'w+', headers: true).columns).must_be_nil}
    end

    it "writes an existing file under w, and appends under a" do
      with_file do |path|
        SimpleCSV.open(path, mode: 'w', headers: true, columns: [:a, :b], quote: :none){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}
        _(File.read(path)).must_equal "a,b\n1,2\n"
      end
      with_file do |path|
        SimpleCSV.open(path, mode: 'a', columns: [:a, :b, :c], quote: :none){|csv| csv.rows = [{'a' => 7, 'b' => 8, 'c' => 9}]; csv.write}
        _(File.read(path)).must_equal "a,b,c\n1,2,3\n4,5,6\n7,8,9\n"
      end
    end

    it "rewrites a file in place under r+ when the rows are read, changed and written" do
      with_file do |path|
        SimpleCSV.open(path, mode: 'r+', headers: true, quote: :none){|csv| csv.rows = csv.read.map{|row| row.merge('a' => 'X')}; csv.write}
        _(File.read(path)).must_equal "a,b,c\nX,2,3\nX,5,6\n"
      end
    end

    it "SimpleCSV.open yields the instance and closes the file" do
      with_file do |path|
        given = nil
        SimpleCSV.open(path, headers: true){|csv| given = csv}
        _(given.instance_variable_get(:@source).closed?).must_equal true
      end
    end

    it "writes a new file by name under a write mode" do
      skip "Decision point 4: Finding 14, a path that does not exist yet is taken as text; the note leans to a write mode making it a path"
      with_file do |path, directory|
        new_path = File.join(directory, 'new.csv')
        SimpleCSV.open(new_path, mode: 'w', headers: true, columns: [:a, :b], quote: :none){|csv| csv.rows = [{'a' => 1, 'b' => 2}]; csv.write}
        _(File.read(new_path)).must_equal "a,b\n1,2\n"
      end
    end

    it "leaves a file as it was when read under r+ without a write" do
      skip "Finding 15: read ends with truncate(0) under r+"
      with_file do |path|
        SimpleCSV.open(path, mode: 'r+', headers: true){|csv| csv.read}
        _(File.read(path)).must_equal DATA
      end
    end

    it ".open constructs one instance, opening the file once" do
      skip "Finding 19: .open constructs an instance and then super constructs another"
      with_file{|path| _(constructions(SimpleCSV::File){SimpleCSV::File.open(path){|csv| }}).must_equal 1}
    end

    it "expands the path it is given" do
      skip "Finding 21: @filename is already set, so the ||= never expands it"
      with_file do |path, directory|
        _(SimpleCSV::File.new(File.join(directory, '.', 'data.csv')).filename).must_equal path
      end
    end
  end
end
