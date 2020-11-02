```
                          _      _     _ 
 ___  ___  ___  ___  ___ | | ___\  \ /  /
|  _|| _ ||   ||  _|| _ || ||  _|\  v  /
|_|  |  _||_|_||___||___\|_||___| \___/
     |_|
```

This is a compiler for RPNCalc5, the coolest new functional, declarative and concatenative stack-based programming language around!

This version compiles to x86_64 for **Linux** (I am not willing to mess around with the windows API, although probably could port it to Mac).
Note that you need to assemble `host.asm` and `memory.asm` in `generator/asm2/raw` to use the x86_64 backend.

## Language by Example
Here's how you write the swap function:
```
(a b -> b a)
```
easy, right? You can read this as 'pop b then a, then push b then a'. That's cool, but what happens if we want to use this multiple times? Simple, let's define it, and some other functions for good measure:
```
(swap; a b -> b a)
(rot; a b c -> b c a)
(drop; a ->)
```
OK! To do arithmetic, import the `arith` library at the top of the file:
```
(# import arith #)
```
`arith` doesn't have a `double` operation yet... let's make one:
```
(double; 2 arith.*)
```
hmm... the `arith.` is a bit cumbersome. `include` the library to use it's namespace:
```
(# include arith #)
...
(double; 2 *)
```
Let's double `4` and define it as `doublefour`:
```
(doublefour; 4 double)
```
Finally, let's add 3 to it and output it in hexidecimal, by importing `io` at the top of the file:
```
(# import io #)
...
doublefour 3 + io.putint
```
This and other tested examples can be found in the `examples` folder (including lazy lists!), in files with a `.rpnc` ending.

## Concatenative style
By using the `'` pseudo-op, that forces RPNCalc to push a closure onto the stack, one is able to simulate concatenative programming techniques. For example, instead of defining `sum` like:
```
(sum; xs -> xs 0 '+ <+)
```
one can use `'` to define it like:
```
(sum; 0 '+ '<+)
```

## Extra Syntax

Strings are simply lists of ints, and so you need to `include list` in order to use them:
```
(# include list #)
`Hello, RPNCalc!`
```

## A bit of history
RPNCalc is - wait for it - a reverse-polish notation, stack-based, calculator. It was originally envisioned by [Oliver Marks](https://osmarks.tk/) as a project for his website *ages* ago. It has since been expanded and built upon until RPNCalcV3, which had limited support for built-in higher-order functions. I decided to expand upon this and redesign RPNCalc with support for closures, lambdas and letexprs. Originally I made a JS [interpreter](https://rpn.aidanpe.duckdns.org) for RPNCalcV4, but for some reason I decided I wanted to compile it. Documentation for RPNCalcV4 is *very* sparse (I promise I'll possibly maybe get round to that), but can mostly be found with the interpreter. If you are interested in the language, I wrote a simple calculator program in it which is hosted [here](https://meta.rpn.aidanpe.duckdns.org). The source for it can be found at `/test.rpn`. After a while, the compiled version became different enough from the web version for me to call it RPNCalc5.

## Useage
N.B. To use you will need to assemble the `*.asm` files (except `macro.asm`) in `/generator/asm2/raw`, and probably also create a `build` folder in `/generator/asm2/`, as git will not save empty folders. To use the standard library, you will also need to compile the `*.asm` files in `/examples/std/`.

To compile, simply run `python3 <main.py location> <input file> <output file> <backend>`. Current backends are:

- `asm`
- `asm2`

It is strongly advised that you use `asm2` as `asm` only exists for legacy reasons, and is incompatible with the current standard library.

## WHY PYTHON???
I would like to have used Haskell, but for my Computer Science A-Level in 2 years we apparently have to use Python, so I thought it would be good to get some practice.
