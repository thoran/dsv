# dsv/PROPOSED.md

Date: 20261111

What is undecided, under a heading for each theme or change, a theme's heading matching ROADMAP.md's. What each release does is in ROADMAP.md; the jobs are in TODO. Not listed in the gemspec, so it does not ship with the gem.

## Rows which contradict their declaration

- The option's name. `on_error:` was the first proposal. `unexpected:` fits the language of declarations, and covers a field count as well as quoting: `quote: :double, unexpected: :mixed`.
- A chain, such as `[:mixed, :skip]`, each step broader than the one before.
- The exception raised. One proposal: `DSV::Error` as a base, `DSV::UnexpectedRow` beneath it with the line and the mode in force, and `UnterminatedQuote` moved beneath that, keeping its name so that existing rescues still work.

## 0.13.x and the version rule

`:single` and `filter` add vocabulary, so the version rule makes each at least a minor. Whether they come as fixes in 0.13.x, as what SimpleCSV meant, or in a minor.

## The scanner-based parser

Whether it replaces the string operations used now, once judged against them.

## Writing

- A row terminator inside a field: kept, quoted, or folded to a space.
- The encoding declared, and a transcode offered with any loss marked.

## Duplicate headers

The option's name.

## The quote character apart from the mode

`quote_char:`, so that a mode declares how fields are quoted and the character is said separately. Whether it comes, and how it sits beside `:single`.

## Unquoted empty fields

An option reading an unquoted empty field as `nil`, named as stdlib CSV's `nil_value:` and `empty_value:` are; without it, a value stays a String. Whether it comes, and its name.

## A drop-in for stdlib CSV

A dialect option, such as `dialect: :ruby_csv`, bundling stdlib CSV's choices, is an idea only. Not `quote: :stdlib`: the empty-field difference is about values, not quoting, and "like stdlib" would commit dsv to following every change stdlib makes.

## Selection as a keyword

- Its name, `only:` or `select:`, `columns:` being taken.
- Whether the positional form is kept or retired.
- `selected_columns:` renamed to match.

## Byte-order marks and lone CRs

Whether either is default behaviour or an option.

## Split-and-unwrap

0.9.9's `:double` split a row and unwrapped each field, which reads rows of bare fields among quoted ones fast. Since 0.11.4 `:double` declares every field quoted. A mode for split-and-unwrap may come, if wanted, under a name saying what it declares.

## Path or text

From 2.0: `.read` taking paths only and `.parse` text only, and a missing path raising.
