# dsv/benchmark/README.md

Scripts measuring how fast DSV reads and writes, and what it allocates, against stdlib CSV. Measurements, not tests: the tests check results only. Not listed in the gemspec, so they do not ship with the gem.

## The scripts

The samples, in `samples.rb`, are 100,000 rows of ten fields each: `quoted`, every field wrapped in double quotes; `mixed`, every other field quoted and holding a comma; and `plain`, no quotes at all.

`read_and_write.rb` times reading each sample and writing, as the best of 5 runs, with the objects made a row. DSV reads each into Hashes, as it does by default, and into Arrays, under `as_array:`; stdlib CSV reads into Arrays. Given a directory, it reads each file in it too, and writes those rows back instead of the mixed sample's. Run it once for DSV and once for stdlib CSV, so that each is timed in a process of its own:

    ruby benchmark/read_and_write.rb lib
    ruby benchmark/read_and_write.rb csv

To compare a released version, unpack its lib into a directory of its own and point the script there:

    git archive v0.16.2 lib | tar -x -C /some/directory
    ruby benchmark/read_and_write.rb /some/directory/lib

`allocations.rb` lists each line in a lib directory which makes objects while 1,000 rows of a sample are read into Hashes, or into Arrays under `--as-array`, with how many it makes a row. The sample and quote mode are optional:

    ruby benchmark/allocations.rb lib
    ruby benchmark/allocations.rb lib plain none
    ruby benchmark/allocations.rb --as-array lib plain none

`layers.rb` reads the plain sample one layer of DSV's work under `:none` at a time, without DSV itself: split alone; through a lambda, as the reader chosen for a mode is called; into a Hash keyed by position, as `parse_fields()` builds and DSV gives by default; and back to an Array, as `as_array:` gives.

## Findings at 0.16.3 and 0.17.0

On Ruby 4.0.7 with stdlib CSV 3.3.6, arm64. The files are a day of NEMWEB's dispatch files, 288 of them, 340,069 rows. Seconds, best of 5, then objects made a row. Runs differ by up to a tenth.

Reading into Hashes, DSV's default, against stdlib CSV reading into Arrays:

| Reading | 0.16.2 | 0.16.3 | 0.17.0 | stdlib CSV |
|---|---|---|---|---|
| the files, default | 2.50, 82.7 | 2.02, 36.7 | 2.08, 36.7 | 1.29, 24.3 |
| quoted, default | 0.95, 108 | 0.73, 48 | 0.70, 48 | 0.38, 24 |
| quoted, `:double` | 0.32, 21 | 0.35, 20 | 0.36, 20 | |
| mixed, default | 0.81, 73 | 0.70, 38 | 0.67, 38 | 0.69, 36 |
| plain, default | 0.44, 37 | 0.32, 17 | 0.32, 17 | 0.24, 14 |
| plain, `:none` | 0.20, 15 | 0.20, 15 | 0.18, 15 | |
| **Writing** the files | 1.58, 57 | 1.63, 57 | 1.59, 57 | 1.24, 3 |

Reading into Arrays, under `as_array:`:

| Reading | 0.16.2 | 0.16.3 | 0.17.0 |
|---|---|---|---|
| the files, default | 2.96, 86.7 | 2.46, 40.7 | 2.50, 40.7 |
| quoted, default | 1.13, 112 | 0.83, 52 | 0.84, 52 |
| quoted, `:double` | 0.46, 25 | 0.42, 24 | 0.44, 24 |
| mixed, default | 1.01, 77 | 0.85, 42 | 0.81, 42 |
| plain, default | 0.57, 41 | 0.44, 21 | 0.44, 21 |
| plain, `:none` | 0.31, 19 | 0.32, 19 | 0.30, 19 |

Stdlib CSV has no modes; its default reads each sample as it reads them all, so its figures above stand against `:double` and `:none` too. Under a mode declared, DSV's Hashes are read faster than stdlib CSV's Arrays: 0.36 s against 0.38 s for the quoted sample, and 0.18 s against 0.24 s for the plain one. It is in the default mode, which looks for quotes in every row, that DSV is slower, except on the mixed sample, where the two are level. Every `as_array:` figure is slower than its Hash one, since the Array is made from the Hash.

0.17.0, which chooses a mode's reader once when the mode is set, measures as 0.16.3 does.

### Frozen literals, 0.16.3

Without `frozen_string_literal: true`, each String literal is a new String every time it is reached: `'"'` and `'""'` in the quoted reader were made several times for each quoted field. Reading the files into Arrays under 0.16.2 and then 0.16.3:

| | 0.16.2 | 0.16.3 |
|---|---|---|
| objects | 29.5 million | 13.8 million |
| minor collections | 598 | 342 |
| major collections | 91 | 11 |
| time collecting | 627 ms | 331 ms |

Fewer objects means fewer collections, and fewer objects surviving one collection to be promoted, so far fewer major ones. Writing was unchanged, at 57 objects a row either way.

### Where the objects go, 0.16.3

Reading the quoted sample into Hashes in the default mode makes 48 objects a row. 46 of them are traced to a line:

| a row | made by |
|---|---|
| 30 | `piece.delete_prefix('"').delete_suffix('"').gsub('""', '"')` in `split_quoted()`: three Strings a field |
| 11 | `row.split(separator, -1)`: the Array and ten pieces |
| 2 | the line read, and the Array made by splatting `selected_columns` to `parse_fields()` |
| 1 | `raw_row.chomp(@row_separator)` |
| 1 | the `fields` Array built in `split_quoted()` |
| 1 | the Hash `parse_fields()` builds, which is the row |

The other 2 are gone by the time the objects are listed, and so are not traced. Under `as_array:` it is 52: the Range and Array the Hash is turned back into, and 2 more untraced. Under `:none`, reading the plain sample into Hashes, it is 15: the same, without the 30 and the `fields` Array.

### Hashes, and Arrays from them

Under `:none`, DSV splits a line as stdlib CSV does, and then puts each field into a Hash keyed by its position, in a block called once a field. Under `as_array:` it then reads them back out into a new Array, in another such block. `layers.rb`, on the plain sample:

| | seconds | objects a row |
|---|---|---|
| split alone | 0.054 | 15 |
| through a lambda | 0.079 | 15 |
| into a Hash | 0.177 | 16 |
| back to an Array | 0.291 | 20 |

So of `:none`'s 0.18 s into Hashes, 0.10 s is putting the fields into the Hash, and `as_array:` spends 0.11 s more taking them out again. Stdlib CSV, at 0.24 s, makes no Hash, but counts the quotes in each field in a `while` loop. TODO has the job under Speed, results unchanged: `as_array:` returning the split fields, which would bring `as_array:` close to the 0.08 s of the split alone, without touching the Hash path.

### Fewer objects

Besides the jobs under Speed, results unchanged, these each leave results as they are:

- One String for a quoted field, as stdlib CSV makes: `piece[1..-2]`, with `gsub` only where the field holds `""`. This saves two Strings a quoted field.
- Lines read by `each(@row_separator, chomp: true)`, rather than chomped after.
- `parse_fields()` taking the selected columns as an Array rather than splatted.
- The Array `split` returns filled in place with each unwrapped field, as stdlib CSV does, rather than a new `fields` Array.

These would bring the quoted sample into Hashes from 48 objects a row to about 25, the Hash being the one more than stdlib CSV's 24; and the plain sample under `:none` from 15 to about 13.

### Writing

DSV makes 57 objects a row writing the files, where stdlib CSV makes 3, though it takes only about a third as long again. DSV writes Hash rows, and stdlib CSV was given Arrays, so the two are not alike; but most of the 54 is the writer's own, and none of the above touches it.
