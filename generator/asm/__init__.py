import generator
import subprocess
import os
from generator.asm.desugar import irify
import generator.asm.IR
from sys import path
from misc import Relative, Absolute

@generator.libgenerator('asm')
def libasm(input, output, flags, ext):
    offset = 0
    asts = input.getast()
    extern = {**ext, **input.include()}
    out = []
    for sym, ast in asts.items():
        ops = irify(ast, extern)
        blocks = list(map(lambda x : "".join(list(map(lambda y : y.emit(offset), x))), ops))
        thisout = sym + """:
    FUNCTION""" + blocks[0] + """
    RETURN"""
        for i in range(1, len(blocks)):
            thisout += "\n_"+str(offset+i)+":\n    FUNCTION"
            thisout += blocks[i]
        out.append(thisout)
        offset += len(blocks)
    header = """
%include "raw/macro.asm"
""" + "\n".join(["extern "+n for n, _ in ext.values()]) + """
extern scopemem
extern scopelen
""" + "\n".join(["global "+n for n in asts.keys()])
    gen_asm = header + "\n\n" + "\n".join(out)

    currdir = os.getcwd()
    os.chdir(path[0]+"/generator/asm")

    outf = open("build/"+input.name+".asm", "w+")
    outf.write(gen_asm)
    outf.close()

    subprocess.run(['nasm', '-felf64', 'build/'+input.name+'.asm', '-o', 'build/'+output])

    os.chdir(currdir)

@generator.generator('asm')
def asm(input, output, flags, extern, links):
    ops = irify(input, extern)
    a = list(map(lambda x : "".join(list(map(lambda y : y.emit(), x))), ops))
    out = ""
    for i, v in enumerate(a):
        if i == 0:
            out = """
%include "raw/macro.asm"
%define BLOCKS 128

global scopemem
global scopelen
global _0
""" + "".join(list(map(lambda e : "\nextern " + e[0], extern.values()))) + """

section .data
scopelen: dq BLOCKS

section .bss
scopemem: resq BLOCKS*4

section .text
_0:
    FUNCTION""" + v + """
    RETURN"""
        else:
            out += "\n_"+str(i)+":\n    FUNCTION"
            out += v
    
    currdir = os.getcwd()
    links = list(map(lambda p : currdir + '/generator/asm/build/' + p.path if p.__class__ == Relative else p.path, links))
    os.chdir(path[0]+"/generator/asm")

    outf = open("build/build.asm", "w+")
    outf.write(out)
    outf.close()

    subprocess.run(['nasm', '-felf64', 'build/build.asm', '-o', 'build/build.o'])

    if ('-glibc' in flags):
        subprocess.run(['gcc', 'raw/host.c', 'build/build.o', 'raw/memory.o', '-o', 'build/build.out'] + links)
    else:
        subprocess.run(['ld', 'raw/host.o', 'build/build.o', 'raw/memory.o', '-o', 'build/build.out', '-Os', '-Ns'] + links)

    os.rename('build/build.out', currdir+"/"+output)

    os.chdir(currdir)