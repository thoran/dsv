# DSV Roadmap

Date: 20261029

The discrete jobs, by release, are in TODO. Not listed in the gemspec, so it does not ship with the gem.

## Design philosophy

### Modes are declarations

A quote mode says what the file holds, and dsv reads it on that understanding, the speed of each mode coming from what it is allowed to assume. A named mode is gospel: dsv acts as though it were true, and a wrong declaration is the caller's to answer for. `:double` declares every field quoted, and `:none` that quotes are data; the two are treated alike, neither falling back to another reading where a row does not fit.

The default, `:mixed` once it has the name, declares nothing: it reads bare and quoted fields together, as RFC 4180 does, and is not a fast path.

From 0.13.0 a mode raises on a contradiction which costs nothing to see, such as a row under `:double` which does not start with a quote, the header included. Declaring `:mixed` reads such a row. What else may be done with it, skipping it or falling back to another mode, is an option of its own after 1.0, orthogonal to the mode.

### Faster, better and more compliant

Each without costing either of the others. Speed is measured against stdlib CSV, not claimed.

### A drop-in, in some cases

dsv aims to be a faster and easier replacement for stdlib CSV where its defaults suit, so that someone can start from what they know and take up dsv's own ways later.

## The boundary for 1.0

1.0 is SimpleCSV in spirit: what the original design meant, without its bugs, rather than every behaviour it happened to have. A change belongs before 1.0 if the design meant it, in its code, names, CHANGELOG, tests or a stated goal such as speed, and it adds no new vocabulary. Anything else comes after.

## The version rule

A fix is a patch. Anything which is not a fix is at least a minor, as is a fix which turns calls that run today into exceptions. Before 1.0, a change to what a method returns is a minor; after it, a major.

## The release sequence

- 0.12.x: fixes.
- 0.13.0: unknown modes and options raise, `:mixed` names the default, and modes raise on contradictions which cost nothing to see.
- 0.14.0: `each` streams, returning its receiver. A minor rather than a fix, because `each` with a block no longer returns the rows, and `rows` is no longer filled as a side effect; after 1.0 it would have to wait for 2.0.
- 1.0: a corpus checked against stdlib CSV, and the README's speed sentence from a benchmark.
- 1.x: speed, results unchanged; new options, each opt-in.
- 2.0: whether a String is still told to be a path or text by a guess.

## Themes, and what is undecided in each

### Rows which contradict their declaration

From 0.13.0 such a row raises. After 1.0, an option orthogonal to the mode says what else to do with it: `:raise`, the default; `:skip`; a mode to fall back to, `:mixed` or `:none`, which cannot fail; or a block. Perhaps a chain, such as `[:mixed, :skip]`, each step broader than the one before.

Undecided:

- The option's name. `on_error:` was the first proposal. `unexpected:` fits the language of declarations, and covers a field count as well as quoting: `quote: :double, unexpected: :mixed`.
- The exception raised. One proposal: `DSV::Error` as a base, `DSV::UnexpectedRow` beneath it with the line and the mode in force, and `UnterminatedQuote` moved beneath that, keeping its name so that existing rescues still work. Mistakes in the options themselves stay `ArgumentError`.

### The quote character apart from the mode

`quote_char:`, so that a mode declares how fields are quoted and the character is said separately. Undecided whether it comes, and how it sits beside `:single`.

### Unquoted empty fields

An option reading an unquoted empty field as `nil`, named as stdlib CSV's `nil_value:` and `empty_value:` are; without it, a value stays a String. Undecided whether it comes, and its name.

### A drop-in for stdlib CSV

`DSV::CSV`, late in 1.x: stdlib CSV's calls (`read`, `foreach`, `parse`, `parse_line`, `generate_line`, `open` with `<<`) and option names, and its defaults: Arrays without headers, Hashes with them, `:rfc_4180`, `nil` for unquoted empty fields, minimal quoting when writing. Switching would be a search-and-replace of `CSV.` with `DSV::CSV.`.

It depends on `:rfc_4180`, the empty-field option, `quote_char:`, the option for contradicting rows, minimal quoting, a streaming `each`, and the speed work, since "faster" needs that first.

A dialect option, such as `dialect: :ruby_csv`, bundling those choices, is an idea only. Not `quote: :stdlib`: the empty-field difference is about values, not quoting, and "like stdlib" would commit dsv to following every change stdlib makes.

### Selection as a keyword

A selection given by keyword rather than positionally. Undecided: its name, `only:` or `select:`, `columns:` being taken; whether the positional form is kept or retired; and `selected_columns:` renamed to match.

### Guessing

A mode run once at construction on a sample of the first rows, feeding the same chooser as an explicit option: the column separator, the one whose count is the same on every sampled row; whether the first row is a header, its columns' types differing from the rows beneath in the same way across columns; and, where there is no header, a header made from the data, each column named for what its values look like, integer, decimal, date, email, URL, phone, with a positional fallback, `column_0`, and a suffix where two columns share a class. Names come from what values look like, not what they mean; anything more is a schema, and another library's.

### Templated ingestion

A `template:` option taking a whole-row Regexp with a capture per field, the group names being the column names, one match per row; an Array of separators as its writable special case, compiled into such a Regexp at construction and invertible for writing where a general template is not.

### Byte-order marks and lone CRs

A BOM read past, and a lone CR taken as a row separator. Undecided whether either is default behaviour or an option.

### Split-and-unwrap

0.9.9's `:double` split a row and unwrapped each field, which reads rows of bare fields among quoted ones fast. Since 0.11.4 `:double` declares every field quoted. A mode for split-and-unwrap may come, if wanted, under a name saying what it declares.

### Path or text

A String is a path where a file of that name exists and text otherwise. That stays through 1.x. From 2.0 it may be reconsidered: `.read` taking paths only and `.parse` text only, and a missing path raising.
