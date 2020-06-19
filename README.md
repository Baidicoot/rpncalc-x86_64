# Aidan's Toy RPNCalc Compiler (ATRCC)
N.B. To use, you will need to assemble `/generator/asm/raw/memory.asm` to `/generator/asm/raw/memory.o`, (and now `/generator/asm/raw/io.asm`) using `nasm -felf64 memory.asm` etc, otherwise you'll probably get a weird error. I patched a bug where objects were being dropped too early. Also, RPNCalcCompiled has no support for (useful) builtins - although I am working on a module system - and is mostly a proof-of-concept at this point.

This is a compiler for the RPNCalcV4 'programming' 'language' to x86_64 for **Linux** (I am not willing to mess around with the windows API, although probably could port it to Mac).

## About RPNCalc
RPNCalc is - wait for it - a reverse-polish notation, stack-based, calculator. It was originally envisioned by [Oliver Marks](https://osmarks.tk/) as a project for his website *ages* ago. It has since been expanded and built upon until RPNCalcV3, which had limited support for built-in higher-order functions. I decided to expand upon this and redesign RPNCalc with support for closures, lambdas and letexprs. Originally I made a JS [interpreter](https://rpn.aidanpe.duckdns.org) for RPNCalcV4, but for some reason I decided I wanted to compile it. Documentation for RPNCalcV4 is *very* sparse (I promise I'll possibly maybe get round to that), but can mostly be found with the interpreter. If you are interested in the language, I wrote a simple calculator program in it which is hosted [here](https://meta.rpn.aidanpe.duckdns.org). The source for it can be found at `/test.rpn`.

## Useage
To compile, simply run `python3 <main.py location> <input file> <output file> <backend>`. Current backends are: `asm`. You might also need to create a folder named `build` in `/generator/asm`, as git seems to ignore folders with no content. To use the glibc-hosted version, pass the flag `-glibc` after the other arguments.

## WHY PYTHON???
I would like to have used Haskell, but for my Computer Science A-Level in 2 years we apparently have to use Python, so I thought it would be good to get some practice.