import generator
import subprocess
import os
from generator.asm.desugar import irify
import generator.asm.IR
from sys import path

@generator.generator
def asm(input, output, flags):
    extern, ops = irify(input)
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
""" + "".join(list(map(lambda e : "\nextern " + e, extern))) + """

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
    os.chdir(path[0]+"/generator/asm")

    outf = open("build/build.asm", "w+")
    outf.write(out)
    outf.close()

    subprocess.run(['nasm', '-felf64', 'build/build.asm', '-o', 'build/build.o'])

    if ('-glibc' in flags):
        subprocess.run(['gcc', 'raw/host.c', 'build/build.o', 'raw/memory.o', '-o', 'build/build.out'])
    else:
        subprocess.run(['ld', 'raw/io.o', 'build/build.o', 'raw/memory.o', '-o', 'build/build.out', '-Os', '-Ns'])

    os.rename('build/build.out', currdir+"/"+output)

    os.chdir(currdir)