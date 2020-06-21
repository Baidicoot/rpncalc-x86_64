from typing import List, Dict, Tuple
from parser.AST import *

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
        return {k : (self.name+'_'+k, 0) for k in self.exports.keys()}
    
    def imprt(self) -> Dict[str, Tuple[str, int]]:
        return {self.name+'.'+k : (self.name+'_'+k, 0) for k in self.exports.keys()}
    
    def getast(self) -> Dict[str, List[Stmt]]:
        return {self.name+'_'+k : v for k, v in self.exports.items()}