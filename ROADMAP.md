# dsv/ROADMAP.md

Date: 20261125

What each release does, and why, and the themes beyond them. The jobs for the releases in hand, one to a line in the order they are to be done, are in TODO; what is undecided is in PROPOSED.md. Not listed in the gemspec, so it does not ship with the gem.

## Design philosophy

### Modes are declarations

Fail fast, otherwise go fast. Speed is why the modes exist, and the main reason for everything in this section: the fewer checks made on each row and field, the faster dsv reads. A quote mode says what the file holds, and dsv reads it on that understanding, the speed of each mode coming from what it is allowed to assume. A named mode is one direct path, chosen once, checking nothing it may assume: no fallback, no interpretation, no guessing, each of which is a check made on every row or field. A row which contradicts it raises, where the contradiction costs nothing to see, rather than being read some other way. `:double` declares every field quoted, and `:none` that quotes are data; the two are treated alike.

The default, `:unspecified` once it has the name, declares nothing: it reads bare and quoted fields together, as RFC 4180 does, and is not a fast path. It is the one reading which interprets. Whoever wants a row read whichever way it comes wants `:unspecified`, the default: a mode which falls back reads as it does, with its checks added.

Nothing else is guessed either: an unknown mode or option raises, and a source is given as a path or as text, never inferred from whether a file of that name exists.

### Faster, better, and more compliant

Each without costing either of the others. Speed is measured against stdlib CSV, not claimed. Speed comes from keeping the work in Ruby's C: few Ruby-level steps, few allocations, and few checks per row.

### A drop-in, in some cases

dsv aims to be a faster and easier replacement for stdlib CSV where its defaults suit, so that someone can start from what they know and take up dsv's own ways later.

## The boundary for 1.0

1.0 is SimpleCSV in spirit: what the original design meant, without its bugs, rather than every behaviour it happened to have. A change belongs before 1.0 if the design meant it, in its code, names, CHANGELOG, tests or a stated goal such as speed, and it adds no new vocabulary. Anything else comes after.

## The version rule

A fix is a patch. Anything which is not a fix is at least a minor, as is a fix which turns calls that run today into exceptions. Before 1.0, a change to what a method returns is a minor; after it, a major.

## Releases

### 0.13.0: the fallback under `:double` undone

A correction of two errors in 0.12.5, its item 2 (v0.12.5:CHANGELOG#2). In design: a row which breaks `:double` was read as though no mode were named. Chiefly, that costs speed: to know when to fall back, `:double` scans every unquoted row for a quote and counts the quotes in every field holding one, so that the fast path pays for the slow one on every row. And naming the mode stopped saying anything about the rows. In versioning: that changed what the mode means, so it was a minor, released as a patch beside a fix. Undoing it is a minor too, since rows read today will raise, and it comes in a release of its own so as to be seen; its CHANGELOG entry names both errors.

- Under `:double`, a row which contradicts the mode raises where the contradiction costs nothing to see, every row alike, the header included: a row not starting with a quote, and a bare field in a row read in full. Leaving the mode out reads such a row. What else may be done with it comes after 1.0, under Rows which contradict their declaration.
- `DSV::Error`, the base of what dsv raises about the data, so that one rescue catches all of it, with a class of its own beneath it wherever a fault is known more specifically. `UnterminatedQuote` moves beneath it, keeping its name and message, so that a rescue of it still works. `DSV::UnexpectedRow`, carrying the line and the mode in force, is a row which contradicts its declared mode; `DSV::UnquotedField` beneath it, a field with no quotes under a wholly quoted mode, is what this release raises. Mistakes in the options stay `ArgumentError`, being the caller's rather than the data's.

Going back to 0.12.4's reading instead would misread rows which keep the contract, a field holding `","` among them. An unquoted header, which 0.12.4 split plainly too, raises as any other row does, DSV writing its header quoted.

### 0.13.x: fixes

What SimpleCSV meant, without its bugs.

- `filter`, beside `select`.

### 0.14.0: the internals private

Only the instance methods SimpleCSV had, and `repeated_names`, which the README documents, are public. A call to anything else, which runs today, raises `NoMethodError`, which makes this a minor.

- `split_double_quoted()` renamed `split_wholly_quoted()`, its contract being every field quoted, whatever the quote character.

### 0.15.0: modes as declarations

A mode is held to what it declares, and so is everything else given to dsv.

- An unknown quote mode, file mode or option raises `ArgumentError`, where each is ignored today.
- `:unspecified` names the default, which may also be stated.
- The reader is chosen once, when the quote mode is set, as `row_renderer` is for writing, so that no row asks which mode is in force.
- `.read` and `.open` take a path, and `.parse` takes text; a path which does not exist raises. A String is no longer taken as a path or as text by whether a file of that name exists, so a file not yet there can be written by name.
- `:unquoted` names the mode reading no quotes, `:none` kept as an alias, since "none" may be read as no mode named.
- `:single`, read as `:double` is, with a single quote. No release has read it, so it is an addition, not a fix, and it comes once `:double` raises, so as to arrive with no fallback.
- `attributes=` sets `columns`, so that the names are held in one place and `attributes` is always worked out from them; rows read afterwards are keyed by those names. What is written differs from what was read through the selection given to `write`, a column added included.

### 0.16.0: streaming

`each` yields each row as it is read, so that `detect` and `break` stop reading and memory does not grow with the file, and returns its receiver. `rows` is no longer filled as a side effect. The source is read once, start to end, with no rewind, so that a pipe or `$stdin` can be read.

A minor rather than a fix, because `each` with a block no longer returns the rows; after 1.0 it would have to wait for 2.0.

### 1.0: checked and measured

A corpus in the tests, a day of NEMWEB's dispatch files, trimmed, and the RFC 4180 cases, each checked against stdlib CSV's rows. A benchmark script against stdlib CSV, and the README's speed sentence written from its output. The README shows every mode by example, and a table matches each to stdlib CSV's and Python's settings.

### 1.x: speed, results unchanged

Faster without a result changing:

- A per-row fast path for the default: split, the fields bare or wrapped in two quotes unwrapped, any other row read in full.
- `as_array:` returning the split fields, rather than building a Hash and then an Array from it.
- Rows built by `zip.to_h`.
- The scanner-based parser, at the tag scanner-parser-20261006, judged against the string operations used now.

### 1.x: features

New options, each opt-in:

- `:rfc_4180`, a quote mode reading what RFC 4180 allows as `:unspecified` does and raising on what it forbids.
- `field_count:`, `:header` or an Integer, off by default: a row of another width raises.
- Writing with minimal quoting: a field quoted only where it holds a separator, a quote or a row terminator.
- A line number in each parse error, and `line_numbers:`.
- `headers?`, the instance-level `header_row` renamed, `header_row` kept as an alias.
- `<<`, to append a row, and `generate`, to build a string.
- Symbols and Strings interchangeable for column names, in a selection, a `columns:` list and a row's keys.
- Duplicate headers by option: all kept as an Array, the default; indexed, `a`, `a.1`; first; last; error.

A line number in a parse error is found only when the error is raised, as `UnterminatedQuote` finds its, where the source can seek. `line_numbers:` counts lines as it reads instead, for any source, a pipe included; the read loop is chosen once, at construction, so that without it no row pays for the count.

## Themes

### Rows which contradict their declaration

From 0.13.0 such a row raises. After 1.0, an option orthogonal to the mode says what else to do with it: `:raise`, the default; `:skip`; a mode to fall back to, `:unspecified` or `:unquoted`, which cannot fail; or a block. Mistakes in the options themselves stay `ArgumentError`.

### A drop-in for stdlib CSV

`DSV::CSV`, late in 1.x: stdlib CSV's calls (`read`, `foreach`, `parse`, `parse_line`, `generate_line`, `open` with `<<`) and option names, and its defaults: Arrays without headers, Hashes with them, `:rfc_4180`, `nil` for unquoted empty fields, minimal quoting when writing. Switching would be a search-and-replace of `CSV.` with `DSV::CSV.`.

It depends on `:rfc_4180`, the empty-field option, `quote_char:`, the option for contradicting rows, minimal quoting, a streaming `each`, and the speed work, since "faster" needs that first.

### Selection as a keyword

A selection given by keyword rather than positionally.

### Guessing

A mode run once at construction on a sample of the first rows, feeding the same chooser as an explicit option: the column separator, the one whose count is the same on every sampled row; whether the first row is a header, its columns' types differing from the rows beneath in the same way across columns; and, where there is no header, a header made from the data, each column named for what its values look like, integer, decimal, date, email, URL, phone, with a positional fallback, `column_0`, and a suffix where two columns share a class. Names come from what values look like, not what they mean; anything more is a schema, and another library's.

### Templated ingestion

A `template:` option taking a whole-row Regexp with a capture per field, the group names being the column names, one match per row; an Array of separators as its writable special case, compiled into such a Regexp at construction and invertible for writing where a general template is not.

### Byte-order marks and lone CRs

A BOM read past, and a lone CR taken as a row separator.

### Speed against other languages

A benchmark beyond stdlib CSV: Python's `csv` and pandas' C engine, Go's `encoding/csv`, Rust's `csv` crate, Crystal's `CSV`, and DuckDB's `read_csv` as the high-water mark. Fair only where each reads the same files, with the cache alike for all, into the same shape, arrays against arrays and hashes against dicts, and where reading the file is timed apart from parsing it. Ruby's own I/O being fast, a Ruby reader which keeps its work in C can claim more than is expected of one; matching or beating Python's `csv` is the claim worth making.
