# cl-nessie
Simple 6502 Disassembler

This project DOES NOT WORK, as of this very moment. It was inspired by the fact that
the second programming language I ever used was 6502 assembly and that I have been
getting into common lisp more and more as time goes by. I had been thinking about
trying to tackle writing a 6502 disassembler for a bit just for the experience.
Upon discovering the built in FFI inside SBCL while reading through their documents
I thought it would be a handy thing to learn about, didn't know about the CFFI
project yet, so I decided to tackle writing a 6502 disassmebler. Sadly after one
afternoon of thinking and reading sbcl's manual I wrote a little code and stopped
coding on it. I still think the project is a neat little learning experience and
will eventually finish it even if it ends up being a complete rewrite.

UPDATE: rewrote the code using cffi and tweaked the reader.c file, no testing has
  been done yet. Meaning it may may not work at all still.
  
UPDATE: Makefile properly builds shared object file now

UPDATE: cl-nessie.lisp loads with no errors
