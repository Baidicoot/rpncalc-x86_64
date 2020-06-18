# Aidan's Toy RPNCalc Compiler (ATRCC)
N.B. To use, you will need to assemble `/generator/asm/raw/memory.asm` to `/generator/asm/raw/memory.o`, using `nasm -felf64 memory.asm`, otherwise you'll probably get a weird error. Also, there seem to be some strange behaviours occuring with curried functions (i.e. the `a -> (b -> c)` kind), so it's probably better to stick with closures (i.e. `b a -> c`) until I fix that. Also also, RPNCalcCompiled has no support for builtins, and is mostly a proof-of-concept at this point.

This is a compiler for the RPNCalcV4 'programming' 'language' to x86_64 for **Linux** (I am not willing to mess around with the windows API, although probably could port it to Mac).

## About RPNCalc
RPNCalc is - wait for it - a reverse-polish notation, stack-based, calculator. It was originally envisioned by [Oliver Marks](https://osmarks.tk/) as a project for his website *ages* ago. It has since been expanded and built upon until RPNCalcV3, which had limited support for built-in higher-order functions. I decided to expand upon this and redesign RPNCalc with support for closures, lambdas and letexprs. Originally I made a JS [interpreter](https://rpn.aidanpe.duckdns.org) for RPNCalcV4, but for some reason I decided I wanted to compile it. Documentation for RPNCalcV4 is *very* sparse (I promise I'll possibly maybe get round to that), but can mostly be found with the interpreter. If you are interested in the language, I wrote a simple calculator program in it which is hosted [here](https://meta.rpn.aidanpe.duckdns.org). The source for it can be found at `/test.rpn`.

## Useage
To compile, simply run `python3 <main.py location> <input file> <output file> <backend>`. Current backends are: `asm`.