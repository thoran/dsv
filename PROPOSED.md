# dsv/PROPOSED.md

What is undecided, under a heading for each theme or change, a theme's heading matching ROADMAP.md's. Why each release is made is in ROADMAP.md; the jobs are in TODO. Not listed in the gemspec, so it does not ship with the gem.

## Rows which contradict their declaration

- The option's name. `on_error:` was the first proposal. `unexpected:` fits the language of declarations, and covers a field count as well as quoting: `quote: :double, unexpected: :unspecified`.
- A chain, such as `[:unspecified, :skip]`, each step broader than the one before.
- `:collect`, a choice for the option: each row which contradicts its mode is kept with its line, reading goes on to the end, and there one error is raised holding them all, so that a file can be checked whole in one pass. Nothing is kept or checked on a row which keeps its mode. Whether the rows read are returned beside the error, and its name, such as `DSV::UnexpectedRows`.

## The scanner-based parser

Whether it replaces the string operations used now, once judged against them.

## Writing

- A row terminator inside a field: kept, quoted, or folded to a space.
- The encoding declared, and a transcode offered with any loss marked.

## Duplicate headers

The option's name.

## The quote character apart from the mode

`quote_char:`, so that a mode declares how fields are quoted and the character is said separately. Whether it comes, and how it sits beside `:single`. Quotes are counted a byte at a time, which is cheapest, so any character of one byte in an ASCII-compatible encoding can be one; a character of more than one byte would want counting by character, which is slower, or to be refused.

## Unquoted empty fields

An option reading an unquoted empty field as `nil`, named as stdlib CSV's `nil_value:` and `empty_value:` are; without it, a value stays a String. Whether it comes, and its name.

## A drop-in for stdlib CSV

A dialect option, such as `dialect: :ruby_csv`, bundling stdlib CSV's choices, is an idea only. Not `quote: :stdlib`: the empty-field difference is about values, not quoting, and "like stdlib" would commit dsv to following every change stdlib makes.

## Selection as a keyword

- Its name, `only:` or `select:`, `columns:` being taken.
- Whether the positional form is kept or retired.
- `selected_columns:` renamed to match.

## Guessing

- `:infer`: the quote mode read off the first row, taken as an exemplar where the caller directs it, and then held to as a named mode is, so that the rest of the file reads fast: a later row which contradicts it raises, as it would had that mode been named. It would be the only mode besides those named and `:unspecified`.
- A fallback for `:infer` only where asked, as for any mode, by the option under Rows which contradict their declaration: `quote: :infer, unexpected: :unspecified` reads a row which contradicts the inferred mode as unspecified.
- Which row is the exemplar under `headers: true`: the header, or the first row beneath it, a header often being unquoted where the rows beneath are quoted.

## Byte-order marks and lone CRs

Whether either is default behaviour or an option.

## Split-and-unwrap

0.9.9's `:double` split a row and unwrapped each field, which reads rows of bare fields among quoted ones fast. Since 0.11.4 `:double` declares every field quoted. A mode for split-and-unwrap may come, if wanted, under a name saying what it declares.

## Path or text

How `DSV.new` is told whether a String is a path or text, now that neither is inferred.
