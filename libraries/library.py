from typing import List, Dict, Tuple
from parser.AST import *

def sanitize(str):
    replacements = {
        '|': "_tok_pipe",
        '!': "_tok_exp",
        '`': "_tok_btick",
        '¬': "_tok_not",
        '$': "_tok_dollar",
        '%': "_tok_percent",
        '^': "_tok_uparr",
        '&': "_tok_amp",
        '*': "_tok_asterisk",
        '_': "_tok_underscore",
        '-': "_tok_minus",
        '+': "_tok_plus",
        '=': "_tok_equals",
        '{': "_tok_lcurly",
        '[': "_tok_lsquare",
        '}': "_tok_rcurly",
        ']': "_tok_rsquare",
        ':': "_tok_colon",
        '@': "_tok_at",
        '~': "_tok_tilde",
        '#': "_tok_sharp",
        '<': "_tok_rangled",
        ',': "_tok_comma",
        '>': "_tok_langled",
        '.': "_tok_period",
        '?': "_tok_question",
        '/': "_tok_rslash",
        '\\': "_tok_lslash"
    }
    out = ""
    for ch in str:
        if ch in replacements.keys():
            out += replacements[ch]
        else:
            out += ch
    return out

class Library:
    def __init__(self, decls: List[Decl]):
        self.exports: Dict[str, List[Stmt]] = {}
        self.imprts: List[str] = []
        self.includes: List[str] = []
        self.name = None
        for x in decls:
            if x.__class__ == Import:
                self.imprts.append(x.name)
            elif x.__class__ == Include:
                self.includes.append(x.name)
            elif x.__class__ == Export:
                if x.name in self.exports.keys():
                    raise BaseException('REEXPORT OF SYMBOL '+x.name)
                self.exports[x.name] = x.exprs
            elif x.__class__ == LibName:
                if self.name is not None:
                    raise BaseException('RENAMING OF LIBRARY '+self.name+' TO '+x.name)
                self.name = x.name
        if self.name is None:
            raise BaseException('LIBRARY UNNAMED')
    
    def include(self) -> Dict[str, Tuple[str, int]]:
        return {k : (self.name+'_'+sanitize(k), 0) for k in self.exports.keys()}
    
    def imprt(self) -> Dict[str, Tuple[str, int]]:
        return {self.name+'.'+k : (self.name+'_'+sanitize(k), 0) for k in self.exports.keys()}
    
    def getast(self) -> Dict[str, List[Stmt]]:
        return {self.name+'_'+sanitize(k) : v for k, v in self.exports.items()}
    
    def __eq__(self, other):
        if isinstance(other, Library):
            return self.exports == other.exports and self.imprts == other.imprts and self.includes == other.includes and self.name == other.name
        else:
            return False