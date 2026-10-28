# DSV Roadmap

Date: 20261029

Not listed in the gemspec, so it does not ship with the gem. The work itself, by release, is in TODO.

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

## Open questions

### The name of the option for a row which contradicts its declaration

`on_error:` was the first proposal. `unexpected:` fits the language of declarations, and covers a field count as well as quoting: `quote: :double, unexpected: :mixed`.

### The exception such a row raises

One proposal: `DSV::Error` as a base, `DSV::UnexpectedRow` beneath it with the line and the mode in force, and `UnterminatedQuote` moved beneath that, keeping its name so that existing rescues still work. Mistakes in the options themselves stay `ArgumentError`.
