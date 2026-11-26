# dsv/ROADMAP.md

Date: 20261126

Why each release is made, and the themes beyond them. The jobs, one to a line in the order they are to be done, are in TODO, under headings naming the releases here, without their versions; what is undecided is in PROPOSED.md. Not listed in the gemspec, so it does not ship with the gem.

## Design philosophy

### Modes are declarations

Fail fast, otherwise go fast. Speed is why the modes exist, and the main reason for everything in this section: the fewer checks made on each row and field, the faster dsv reads. A quote mode says what the file holds, and dsv reads it on that understanding, the speed of each mode coming from what it is allowed to assume. A named mode is one direct path, chosen once, checking nothing it may assume: no fallback, no interpretation, no guessing, each of which is a check made on every row or field. A row which contradicts it raises, where the contradiction costs nothing to see, rather than being read some other way. `:double` declares every field quoted, and `:none` that quotes are data; the two are treated alike.

The default, `:unspecified` once it has the name, declares nothing: it reads bare and quoted fields together, as RFC 4180 does, and is not a fast path. It is the one reading which interprets. Whoever wants a row read whichever way it comes wants `:unspecified`, the default: a mode which falls back reads as it does, with its checks added.

Nothing else is guessed either: an unknown mode or option raises, and a source is given as a path or as text, never inferred from whether a file of that name exists, so that a file not yet there can be written by name.

### Faster, better, and more compliant

Each without costing either of the others. Speed is measured against stdlib CSV, not claimed. Speed comes from keeping the work in Ruby's C: few Ruby-level steps, few allocations, and few checks per row.

### A drop-in, in some cases

dsv aims to be a faster and easier replacement for stdlib CSV where its defaults suit, so that someone can start from what they know and take up dsv's own ways later.

## The boundary for 1.0

1.0 is SimpleCSV in spirit: what the original design meant, without its bugs, rather than every behaviour it happened to have. A change belongs before 1.0 if the design meant it, in its code, names, CHANGELOG, tests or a stated goal such as speed, and it adds no new vocabulary. Anything else comes after.

## The version rule

A fix is a patch. Anything which is not a fix is at least a minor, as is a fix which turns calls that run today into exceptions. Before 1.0, a change to what a method returns is a minor; after it, a major.

## Releases

### 0.17.0: modes as declarations

A mode is held to what it declares, and so is everything else given to dsv: what is ignored or inferred today raises, which makes this a minor. A mode's name says what it declares, and "none" may be read as no mode named. Column names are held in one place, so that what is written differs from what was read only through the selection given to `write`.

### 0.18.0: streaming

Rows are read as they are wanted, so that `detect` and `break` stop reading and memory does not grow with the file; and the source is read once, start to end, so that a pipe or `$stdin` can be read.

A minor rather than a fix, because `each` with a block no longer returns the rows; after 1.0 it would have to wait for 2.0.

### 1.0: checked and measured

Before the API is fixed, what dsv reads is checked and its speed measured, rather than claimed.

### 1.x: speed, results unchanged

Faster without a result changing.

### 1.x: features

New options, each opt-in, so that nothing read before reads differently.

A line number in a parse error is found only when the error is raised, as `UnterminatedQuote` finds its, where the source can seek. `line_numbers:` counts lines as it reads instead, for any source, a pipe included; the read loop is chosen once, at construction, so that without it no row pays for the count.

## Themes

### Rows which contradict their declaration

From 0.13.0 such a row raises. Reading it as 0.12.4 did, split plainly, is not gone back to: that misreads rows which keep the contract, a field holding `","` among them. After 1.0, an option orthogonal to the mode says what else to do with it: `:raise`, the default; `:skip`; a mode to fall back to, `:unspecified` or `:unquoted`, which cannot fail; or a block. Mistakes in the options themselves stay `ArgumentError`.

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
