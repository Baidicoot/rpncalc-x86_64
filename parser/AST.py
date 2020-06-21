from typing import List

"""
data Stmt -- 'MaybePush' would be clearer?
    = Push Expr
    | SingleExpr Expr
    | Definition str [Stmt]

data Expr
    = Int int
    | Str str
    | Lambda [str] [Stmt]
"""

class Decl:
    pass

class Stmt:
    pass

class Expr:
    pass

# case class definitions:
class Import(Decl):
    def __init__(self, file: str):
        self.name = file
    
    def __repr__(self):
        return "Import(" + self.name + ")"

class Include(Decl):
    def __init__(self, file: str):
        self.name = file
    
    def __repr__(self):
        return "Include(" + self.name + ")"
    
class Export(Decl):
    def __init__(self, name: str, exprs: List[Stmt]):
        self.name = name
        self.exprs = exprs
    
    def __repr__(self):
        return "Export(" + self.name + "," + str(self.exprs) + ")"

class LibName(Decl):
    def __init__(self, name: str):
        self.name = name
    
    def __repr__(self):
        return "Lib("+self.name+")"

class Push(Stmt):
    def __init__(self, expr: Expr):
        self.elem = expr
    
    def __repr__(self):
        return "Push(" + repr(self.elem) + ")"

class SingleExpr(Stmt):
    def __init__(self, expr: Expr):
        self.elem = expr
    
    def __repr__(self):
        return "SExpr(" + repr(self.elem) + ")"

class Definition(Stmt):
    def __init__(self, name: str, exprs: List[Stmt]):
        self.ident = name
        self.body = exprs
    
    def __repr__(self):
        return "Definition(" + repr(self.ident) + "," + repr(self.body) + ")"

class Int(Expr):
    def __init__(self, val: int):
        self.val = val
    
    def __repr__(self):
        return "Int(" + repr(self.val) + ")"

class Str(Expr):
    def __init__(self, val: str):
        self.val = val
    
    def __repr__(self):
        return "Str(" + repr(self.val) + ")"

class Ident(Expr):
    def __init__(self, name: str):
        self.name = name
    
    def __repr__(self):
        return "Ident(" + repr(self.name) + ")"

class Lambda(Expr):
    def __init__(self, args: List[str], body: List[Stmt]):
        self.args = args
        self.body = body
    
    def __repr__(self):
        return "Lambda(" + repr(self.args) + "," + repr(self.body) + ")"