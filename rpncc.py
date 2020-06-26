#!/usr/bin/env python3
import os
import os.path
import parser
import modules
import libraries
import libraries.library
import generator
import generator.asm
import generator.asm2
from sys import argv
from misc import Absolute, Relative

from typing import Callable, List, Dict, Tuple, NoReturn

def getfiles():
    return os.listdir()

mods = {}
libs = {}

def loadmods(file):
    print("parsing modules in " + file + "... ", end="")
    mod = modules.parsemod(open(file).read(), os.path.abspath(os.path.dirname(file)))
    if mod is None:
        print("COULD NOT PARSE MODULE FILE", file)
        exit(1)
    for m in mod:
        if m.name in mods.keys():
            print("MODULE", m.name, "IS REDEFINED IN FILE", file)
            exit(2)
        mods[m.name] = m
    print("done.")

def loadlib(file):
    print("parsing library " + file + "... ", end="")
    lib = libraries.parselib(open(file).read())
    if lib is None:
        print("COULD NOT PARSE LIB FILE", file)
        exit(3)
    if lib.name in libs.keys():
        print("LIBRARY", lib.name, "IS REDEFINED IN FILE", file)
        exit(4)
    libs[lib.name] = lib
    print("done.")

def initextern():
    files = getfiles()
    for file in files:
        if file.endswith('.rpnm'):
            loadmods(file)
        elif file.endswith('.rpnl'):
            loadlib(file)

compiled_libs = []
compiled_mods = []
tolink = []

flags = []

libgen = None
gen = None

def compilelib(name, ignorelibs, ignoremods, backend):
    if name not in libs.keys():
        print("MODULE/LIBRARY", name, "DOES NOT EXIST")
        exit(5)
    externs = genexterns(libs[name].imprts, libs[name].includes, [name] + ignorelibs, ignoremods, backend)
    print("compiling library " + name + "... ", end="")
    libgen(libs[name], name+'.o', flags, externs)
    print("done.")

def imprt(name, ignorelibs, ignoremods, backend):
    extern = {}
    if name in mods.keys() and name not in ignoremods:
        if name not in compiled_mods:
            compiled_mods.append(name)
            if backend not in mods[name].files.keys():
                print("BACKEND", backend, "DOES NOT EXIST FOR LIBRARY", name)
                exit(8)
            tolink.extend(map(lambda p : Absolute(mods[name].path+'/'+p), mods[name].files[backend]))
        extern.update(mods[name].imprt())
    if name in libs.keys() and name not in ignorelibs:
        if name not in compiled_libs:
            compiled_libs.append(name)
            compilelib(name, ignorelibs, ignoremods, backend)
            tolink.append(Relative(name+'.o'))
        extern.update(libs[name].imprt())
    if extern == {}:
        print("MODULE/LIBRARY", name, "DOES NOT EXIST")
        exit(5)
    else:
        return extern

def include(name, ignorelibs, ignoremods, backend):
    extern = {}
    if name in mods.keys() and name not in ignoremods:
        if name not in compiled_mods:
            compiled_mods.append(name)
            if backend not in mods[name].files.keys():
                print("BACKEND", backend, "DOES NOT EXIST FOR LIBRARY", name)
                exit(8)
            tolink.extend(map(lambda p : Absolute(mods[name].path+'/'+p), mods[name].files[backend]))
        extern.update(mods[name].include())
    if name in libs.keys() and name not in ignorelibs:
        if name not in compiled_libs:
            compiled_libs.append(name)
            compilelib(name, ignorelibs, ignoremods, backend)
            tolink.append(Relative(name+'.o'))
        extern.update(libs[name].include())
    if extern == {}:
        print("MODULE/LIBRARY", name, "DOES NOT EXIST")
        exit(5)
    else:
        return extern

def genexterns(imprts, includes, ignorelibs, ignoremods, backend):
    extern = {}
    for i in imprts:
        fns = imprt(i, ignorelibs, ignoremods, backend)
        inter = fns.keys() & extern.keys()
        if len(inter) > 0:
            print("NAME COLLISION(s):", inter)
            exit(6)
        extern.update(fns)
    for i in includes:
        fns = include(i, ignorelibs, ignoremods, backend)
        inter = fns.keys() & extern.keys()
        if len(inter) > 0:
            print("NAME COLLISION(s):", inter)
            exit(6)
        extern.update(fns)
    return extern

def compile(argv):
    global libgen
    global gen
    initextern()

    if len(argv) < 4:
        print("INVALID ARGUMENTS SUPPLIED")
        exit(0)
    input = argv[1]
    output = argv[2]
    backend = argv[3]

    if backend not in generator.generators:
        print("BACKEND", backend, "DOES NOT EXIST")
        exit(7)
    
    if backend not in generator.libgenerators:
        print("BACKEND", backend, "DOES NOT EXIST")
        exit(7)
        
    gen = generator.generators[backend]
    libgen = generator.libgenerators[backend]

    infile = open(input).read()
    #if infile[0] == "#":
    #    lines = infile.splitlines()[1:]
    #    infile = "\n".join(lines)
    decls, ast = parser.parser.parse(infile)
    imprts, includes = parser.getexternal(decls)
    external = genexterns(imprts, includes, [], [], backend)

    print("compiling " + input + "... ", end="")
    gen(ast, output, argv[3:], external, tolink)
    print("compiled succesfully.")

if __name__ == "__main__":
    compile(argv)