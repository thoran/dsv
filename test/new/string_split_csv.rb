1997,Ford,E350

In some CSV implementations, leading and trailing spaces or tabs, adjacent to commas, are trimmed. This practice is contentious and in fact is specifically prohibited by RFC 4180, which states, "Spaces are considered part of a field and should not be ignored."
1997, Ford , E350
not same as
1997,Ford,E350

Fields with embedded commas must be enclosed within double-quote characters.
1997,Ford,E350,"Super, luxurious truck"

Fields with embedded double-quote characters must be enclosed within double-quote characters, and each of the embedded double-quote characters must be represented by a pair of double-quote characters.
1997,Ford,E350,"Super, ""luxurious"" truck"

Fields with embedded line breaks must be enclosed within double-quote characters.
1997,Ford,E350,"Go get one now
they are going fast"

In CSV implementations that trim leading or trailing spaces, fields with such spaces must be enclosed within double-quote characters. (See comment about leading and trailing spaces above.)
1997,Ford,E350," Super luxurious truck "
Fields may always be enclosed within double-quote characters, whether necessary or not.
"1997","Ford","E350"
