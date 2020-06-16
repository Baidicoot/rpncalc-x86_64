from parser import parser
from desugar import irify
from typing import List
from IR import Op

def mkIR(str: str) -> Op:
    return irify(parser.parse(str))

def emit(ops: List[List[Op]]) -> str:
    a = list(map(lambda x : "".join(list(map(lambda y : y.emit(), x))), ops))
    out = ""
    for i, v in enumerate(a):
        out += "\n_"+str(i)+":"
        out += v
    return out