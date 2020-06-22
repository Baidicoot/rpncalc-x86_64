#!/usr/bin/env python3
import os
import os.path
import parser
import modules
import libraries
import libraries.library
import generator
import generator.asm
from sys import argv
from misc import Absolute, Relative

from typing import Callable, List, Dict, Tuple, NoReturn

def getfiles():
    return os.listdir()

mods = {}
libs = {}

def loadmods(file):
    mod = modules.parsemod(open(file).read(), os.path.abspath(os.path.dirname(file)))
    if mod is None:
        print("COULD NOT PARSE MODULE FILE", file)
        exit(1)
    for m in mod:
        if m.name in mods.keys():
            print("MODULE", m.name, "IS REDEFINED IN FILE", file)
            exit(2)
        mods[m.name] = m

def loadlib(file):
    lib = libraries.parselib(open(file).read())
    if lib is None:
        print("COULD NOT PARSE LIB FILE", file)
        exit(3)
    if lib.name in libs.keys():
        print("LIBRARY", lib.name, "IS REDEFINED IN FILE", file)
        exit(4)
    libs[lib.name] = lib

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

def compilelib(name, ignorelibs, ignoremods):
    if name not in libs.keys():
        print("MODULE/LIBRARY", name, "DOES NOT EXIST")
        exit(5)
    externs = genexterns(libs[name].imprts, libs[name].includes, [name] + ignorelibs, ignoremods)
    libgen(libs[name], name+'.o', flags, externs)

def imprt(name, ignorelibs, ignoremods):
    extern = {}
    if name in mods.keys() and name not in ignoremods:
        if name not in compiled_mods:
            compiled_mods.append(name)
            tolink.extend(map(lambda p : Absolute(mods[name].path+'/'+p), mods[name].files))
        extern.update(mods[name].imprt())
    if name in libs.keys() and name not in ignorelibs:
        if name not in compiled_libs:
            compiled_libs.append(name)
            compilelib(name, ignorelibs, ignoremods)
            tolink.append(Relative(name+'.o'))
        extern.update(libs[name].imprt())
    if extern == {}:
        print("MODULE/LIBRARY", name, "DOES NOT EXIST")
        exit(5)
    else:
        return extern

def include(name, ignorelibs, ignoremods):
    extern = {}
    if name in mods.keys() and name not in ignoremods:
        if name not in compiled_mods:
            compiled_mods.append(name)
            tolink.extend(map(lambda p : Absolute(mods[name].path+'/'+p), mods[name].files))
        extern.update(mods[name].include())
    if name in libs.keys() and name not in ignorelibs:
        if name not in compiled_libs:
            compiled_libs.append(name)
            compilelib(name, ignorelibs, ignoremods)
            tolink.append(Relative(name+'.o'))
        extern.update(libs[name].include())
    if extern == {}:
        print("MODULE/LIBRARY", name, "DOES NOT EXIST")
        exit(5)
    else:
        return extern

def genexterns(imprts, includes, ignorelibs=[], ignoremods=[]):
    extern = {}
    for i in imprts:
        fns = imprt(i, ignorelibs, ignoremods)
        inter = fns.keys() & extern.keys()
        if len(inter) > 0:
            print("NAME COLLISION(s):", inter)
            exit(6)
        extern.update(fns)
    for i in includes:
        fns = include(i, ignorelibs, ignoremods)
        inter = fns.keys() & extern.keys()
        if len(inter) > 0:
            print("NAME COLLISION(s):", inter)
            exit(6)
        extern.update(fns)
    return extern

if __name__ == "__main__":
    initextern()

    if len(argv) < 4:
        print("INVALID ARGUMENTS SUPPLIED")
        exit(0)
    input = argv[1]
    output = argv[2]
    backend = argv[3]

    if backend not in generator.generators:
        print("BACKEND", gen, "DOES NOT EXIST")
        exit(7)
    
    if backend not in generator.libgenerators:
        print("BACKEND", gen, "DOES NOT EXIST")
        exit(7)
        
    gen = generator.generators[backend]
    libgen = generator.libgenerators[backend]

    decls, ast = parser.parser.parse(open(input).read())
    imprts, includes = parser.getexternal(decls)
    external = genexterns(imprts, includes)

    gen(ast, output, argv[3:], external, tolink)