# elm-pretty-printer

A pretty printing library based on ['A Prettier Printer' by Philip Wadler](https://homepages.inf.ed.ac.uk/wadler/papers/prettier/prettier.pdf).

This version follows Wadler's paper closely, but is actually ported from a Haskell
implementation that is referred to as Wadler/Leijen. Leijen added Column and Nesting
constructors in the document type, which make for easier and more flexible indentation.

I have added the ability to have different ways of joining documents when placing them
on the same line, or breaking them into multiple lines. When placed within a `group`
, the usual `line` function will render as a line break or a space; the `tightline`
will render as a line break or "". The `separators` function allows a string to be
given that is placed between docs on the same line, or after the start of the line
when placing on multiple lines - useful when rendering commas in a list at the start
of the line.

This implementation is usually sufficiently lazy and tail-recursive to perform well
under Elm. Occassionally an exponential blow-up can happen if the `softline` function
is not used carefully. Plase raise a GitHub issue on this if it is not performing well
enough for you.
