# DSV Roadmap

Date: 20261110

What each release does, and why, and the themes beyond them. The jobs, one to a line, are in TODO; what is undecided is in PROPOSED.md. Not listed in the gemspec, so it does not ship with the gem.

## Design philosophy

### Modes are declarations

A quote mode says what the file holds, and dsv reads it on that understanding, the speed of each mode coming from what it is allowed to assume. A named mode is gospel: dsv acts as though it were true, and a wrong declaration is the caller's to answer for. `:double` declares every field quoted, and `:none` that quotes are data; the two are treated alike, neither falling back to another reading where a row does not fit.

The default, `:mixed` once it has the name, declares nothing: it reads bare and quoted fields together, as RFC 4180 does, and is not a fast path.

### Faster, better and more compliant

Each without costing either of the others. Speed is measured against stdlib CSV, not claimed.

### A drop-in, in some cases

dsv aims to be a faster and easier replacement for stdlib CSV where its defaults suit, so that someone can start from what they know and take up dsv's own ways later.

## The boundary for 1.0

1.0 is SimpleCSV in spirit: what the original design meant, without its bugs, rather than every behaviour it happened to have. A change belongs before 1.0 if the design meant it, in its code, names, CHANGELOG, tests or a stated goal such as speed, and it adds no new vocabulary. Anything else comes after.

## The version rule

A fix is a patch. Anything which is not a fix is at least a minor, as is a fix which turns calls that run today into exceptions. Before 1.0, a change to what a method returns is a minor; after it, a major.

## Releases

### 0.12.x: fixes

What SimpleCSV meant, without its bugs.

- The code laid out as SimpleCSV 0.9.9 is: a `when` and its result on one line, joined by `;`, or, where any `when` in the `case` is long, each result on the next line; an assignment from a conditional wrapped in parentheses; `row_renderer` one branch per quote mode.
- `:double` back to 0.12.4's reading: a row not starting with a quote split plainly, one starting with a quote split on quote-separator-quote, and one which leaves a lone quote in a field read in full as wholly quoted.
- `:single`, read as `:double` is.
- `filter`, beside `select`.
- A String under a write mode taken as a path, so that a file not yet there can be written by name.
- The internals private, and the two levels of row splitting named apart: `split_on()` cuts a row at its separators, and each quote mode reads a row into its `*_fields()`.

### 0.13.0: modes as declarations

A mode is held to what it declares, and so is everything else given to dsv.

- An unknown quote mode, file mode or option raises `ArgumentError`, where each is ignored today.
- `:mixed` names the default.
- A mode raises on a contradiction which costs nothing to see, every row alike, the header included: under `:double`, a row not starting with a quote, and a bare field in a row read in full. Declaring `:mixed` reads such a row. What else may be done with it comes after 1.0, under Rows which contradict their declaration.

### 0.14.0: streaming

`each` yields each row as it is read, so that `detect` and `break` stop reading and memory does not grow with the file, and returns its receiver. `rows` is no longer filled as a side effect. The source is read once, start to end, with no rewind, so that a pipe or `$stdin` can be read.

A minor rather than a fix, because `each` with a block no longer returns the rows; after 1.0 it would have to wait for 2.0.

### 1.0: checked and measured

A corpus checked against stdlib CSV, and the README's speed sentence from a benchmark. The README shows every mode by example, and matches each to stdlib CSV's and Python's settings.

### 1.x: speed, results unchanged

Faster without a result changing: a fast path for the default, `as_array:` from the split fields, and the splitter chosen once at construction, as `row_renderer` is for writing.

### 1.x: features

New options, each opt-in: `:rfc_4180`, `field_count:`, minimal quoting when writing, line numbers, `headers?`, `<<` and `generate`, Symbols and Strings alike as column names, and duplicate headers by option.

A line number in a parse error is found only when the error is raised, as `UnterminatedQuote` finds its, where the source can seek. `line_numbers:` counts lines as it reads instead, for any source; the read loop is chosen once, at construction, so that without it no row pays for the count.

### 2.0

Path or text reconsidered, under Path or text in PROPOSED.md.

## Themes

### Rows which contradict their declaration

From 0.13.0 such a row raises. After 1.0, an option orthogonal to the mode says what else to do with it: `:raise`, the default; `:skip`; a mode to fall back to, `:mixed` or `:none`, which cannot fail; or a block. Mistakes in the options themselves stay `ArgumentError`.

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

### Path or text

A String is a path where a file of that name exists and text otherwise. That stays through 1.x.
