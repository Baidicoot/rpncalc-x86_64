import generator
import subprocess
import os
from generator.asm2.desugar import irify
import generator.asm2.IR
from sys import path
from misc import Relative, Absolute

@generator.libgenerator('asm2')
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
    os.chdir(path[0]+"/generator/asm2")

    outf = open("build/"+input.name+".asm", "w+")
    outf.write(gen_asm)
    outf.close()

    subprocess.run(['nasm', '-felf64', 'build/'+input.name+'.asm', '-o', 'build/'+output])

    os.chdir(currdir)

@generator.generator('asm2')
def asm(input, output, flags, extern, links):
    ops = irify(input, extern)
    a = list(map(lambda x : "".join(list(map(lambda y : y.emit(), x))), ops))
    out = ""
    for i, v in enumerate(a):
        if i == 0:
            out = """
%include "raw/macro.asm"
%define BLOCKS 4096

global heaploc
global heapsize
global _0
""" + "".join(list(map(lambda e : "\nextern " + e[0], extern.values()))) + """

section .data
heaploc: dq heap
heapsize: dq 4096*32

section .bss
heap: resb 4096*32

section .text
_0:
    FUNCTION""" + v + """
    RETURN"""
        else:
            out += "\n_"+str(i)+":\n    FUNCTION"
            out += v
    
    currdir = os.getcwd()
    links = list(map(lambda p : path[0] + '/generator/asm2/build/' + p.path if p.__class__ == Relative else p.path, links))
    os.chdir(path[0]+"/generator/asm2")

    outf = open("build/build.asm", "w+")
    outf.write(out)
    outf.close()

    if '-pre' in flags:
        subprocess.run(['nasm', '-felf64', 'build/build.asm', '-o', currdir+'/'+output, '-E'])
        os.chdir(currdir)
        return

    subprocess.run(['nasm', '-felf64', 'build/build.asm', '-o', 'build/build.o'])

    subprocess.run(['ld', 'raw/host.o', 'build/build.o', 'raw/memory.o', '-o', 'build/build.out', '-Os', '-Ns'] + links)

    os.rename('build/build.out', currdir+"/"+output)

    os.chdir(currdir)