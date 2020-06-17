from parser import parser
from desugar import irify
from typing import List
from IR import Op

def mkIR(str: str) -> List[List[Op]]:
    return irify(parser.parse(str))

def emit(ops: List[List[Op]]) -> str:
    a = list(map(lambda x : "".join(list(map(lambda y : y.emit(), x))), ops))
    out = ""
    for i, v in enumerate(a):
        if i == 0:
            out = """
%include "macro.asm"
%define BLOCKS 128

global scopemem
global scopelen
global _0

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
    return out