# dsv

Delimiter-separated values for Ruby: CSV and its relatives, read and written with any delimiter on either side, in three small files.

This began in November 2006 as `csv2to`, became `CSVFile`, then `SimpleCSV`, and was a personal library for twenty years before it was a gem. The 2011 case for it against the CSV parsers of the day was that it was smaller, cleaner, faster, and gave keyed access to a row's columns. The first, second and fourth still hold; the third is measured, not claimed, and will be reported when it is.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dsv'
```

or install it directly:

```shell
$ gem install dsv
```


## Usage

### Reading

A row is a plain Hash keyed by the header, so it merges, serialises and compares as a Hash does:

```ruby
require 'dsv'

DSV.read('people.csv', headers: true)
# => [{"name" => "Ada", "born" => "1815"}, {"name" => "Charles", "born" => "1791"}]
```

Without a header row the keys are positions:

```ruby
DSV.read("1,2,3\n4,5,6\n")
# => [{0 => "1", 1 => "2", 2 => "3"}, {0 => "4", 1 => "5", 2 => "6"}]
```

A String that names an existing file is read as a file; any other String is read as text.

### Selecting columns

Name the columns wanted, by name or by position, and the rows hold only those:

```ruby
DSV.read('people.csv', 'name', headers: true)
# => [{"name" => "Ada"}, {"name" => "Charles"}]

DSV.read('people.csv', headers: true, selected_columns: ['name'])
```

### Enumerating from the class

The Enumerable calls are available on a source directly, each taking the same options:

```ruby
DSV.each('people.csv', headers: true){|row| puts row['name']}
DSV.select('people.csv', headers: true){|row| row['born'] < '1800'}
DSV.detect('people.csv', headers: true){|row| row['name'] == 'Ada'}
DSV.collect('people.csv', headers: true){|row| row['name'].upcase}
```

`foreach`, `map`, `find_all` and `find` are aliases.

### Any delimiter

The column separator is a String or a Regexp; the row separator is a String:

```ruby
DSV.read('people.tsv', headers: true, column_separator: "\t")
DSV.read('people.txt', headers: true, column_separator: /,\s*/)
DSV.read('people.csv', headers: true, row_separator: "\r\n")
```

`col_sep:` and `row_sep:` are accepted as spellings of those. Writing takes the same two options, so a file round-trips through whatever it was read with.

### Quoting

Unspecified, quoting follows RFC 4180: a quoted field may hold the separator or the row separator, a doubled quote inside it reads as one quote, and a row's quotes are read only when the row holds one. Naming a mode is faster, since each is a direct string operation on the contract it names:

```ruby
DSV.read('plain.csv', headers: true, quote: :none)    # no field is quoted; quotes are data
DSV.read('quoted.csv', headers: true, quote: :double)  # every field is quoted, as DSV writes them
```

### Writing

Set the columns, give the rows as Hashes, and write:

```ruby
DSV.open('out.csv', mode: 'w', headers: true, columns: ['name', 'born']) do |dsv|
  dsv.rows = [{'name' => 'Ada', 'born' => 1815}]
  dsv.write
end
# out.csv:
# "name","born"
# "Ada","1815"
```

Every field is quoted, which is the `:double` contract on the way back in, and a quote inside a value is doubled. `quote: :none` writes bare values, `:single` uses single quotes. A `nil` writes as an empty field. Rows without columns defined are written from their own keys, and if the keys are names they become the header.

Under `r+` a file is read, changed and written back in place; reading never alters the file, and the first write replaces it:

```ruby
DSV.open('people.csv', mode: 'r+', headers: true) do |dsv|
  dsv.rows = dsv.read.collect{|row| row.merge('born' => row['born'].to_i + 1)}
  dsv.write
end
```

### Repeated header names

Where the header repeats a name, `columns` maps the name to every position and the row holds the values under that name as an Array, in position order:

```ruby
DSV.columns("a,a,b\n1,2,3\n", headers: true)  # => {"a" => [0, 1], "b" => 2}
DSV.read("a,a,b\n1,2,3\n", headers: true)     # => [{"a" => ["1", "2"], "b" => "3"}]
```

So a value is a String, or an Array where the header repeats the name. `Array(row['a'])` reads a column that may be either, and `repeated_names` says which names those are. Writing spreads an Array back over its positions.

### One line

```ruby
DSV.parse_line("1,\"2,3\",4\n")  # => ["1", "2,3", "4"]
```


## What it is not

There are no converters, no `Row` or `Table` classes, and no encoding handling: a value is always a String, a row is always a Hash. Anything wanted beyond that is in `TODO`, in the order it is likely to arrive.


## License

MIT. See `LICENSE`.
