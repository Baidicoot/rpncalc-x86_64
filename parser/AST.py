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
    
    def __eq__(self, other):
        if isinstance(other, Import):
            return other.name == self.name
        else:
            return False

class Include(Decl):
    def __init__(self, file: str):
        self.name = file
    
    def __repr__(self):
        return "Include(" + self.name + ")"
    
    def __eq__(self, other):
        if isinstance(other, Include):
            return other.name == self.name
        else:
            return False
    
class Export(Decl):
    def __init__(self, name: str, exprs: List[Stmt]):
        self.name = name
        self.exprs = exprs
    
    def __repr__(self):
        return "Export(" + self.name + "," + str(self.exprs) + ")"
    
    def __eq__(self, other):
        if isinstance(other, Export):
            return other.name == self.name and other.exprs == self.exprs
        else:
            return False

class LibName(Decl):
    def __init__(self, name: str):
        self.name = name
    
    def __repr__(self):
        return "Lib("+self.name+")"
    
    def __eq__(self, other):
        if isinstance(other, LibName):
            return other.name == self.name
        else:
            return False

class Push(Stmt):
    def __init__(self, expr: Expr):
        self.elem = expr
    
    def __repr__(self):
        return "Push(" + repr(self.elem) + ")"
    
    def __eq__(self, other):
        if isinstance(other, Push):
            return other.elem == self.elem
        else:
            return False

class SingleExpr(Stmt):
    def __init__(self, expr: Expr):
        self.elem = expr
    
    def __repr__(self):
        return "SExpr(" + repr(self.elem) + ")"
    
    def __eq__(self, other):
        if isinstance(other, SingleExpr):
            return other.elem == self.elem
        else:
            return False

class Definition(Stmt):
    def __init__(self, name: str, exprs: List[Stmt]):
        self.ident = name
        self.body = exprs
    
    def __repr__(self):
        return "Definition(" + repr(self.ident) + "," + repr(self.body) + ")"
    
    def __eq__(self, other):
        if isinstance(other, Definition):
            return other.body == self.body and self.ident == other.ident
        else:
            return False

class Int(Expr):
    def __init__(self, val: int):
        self.val = val
    
    def __repr__(self):
        return "Int(" + repr(self.val) + ")"
    
    def __eq__(self, other):
        if isinstance(other, Int):
            return other.val == self.val
        else:
            return False

class Str(Expr):
    def __init__(self, val: str):
        self.val = val
    
    def __repr__(self):
        return "Str(" + repr(self.val) + ")"
    
    def __eq__(self, other):
        if isinstance(other, Str):
            return other.val == self.val
        else:
            return False

class Ident(Expr):
    def __init__(self, name: str):
        self.name = name
    
    def __repr__(self):
        return "Ident(" + repr(self.name) + ")"
    
    def __eq__(self, other):
        if isinstance(other, Ident):
            return other.name == self.name
        else:
            return False

class Lambda(Expr):
    def __init__(self, args: List[str], body: List[Stmt]):
        self.args = args
        self.body = body
    
    def __repr__(self):
        return "Lambda(" + repr(self.args) + "," + repr(self.body) + ")"
    
    def __eq__(self, other):
        if isinstance(other, Lambda):
            return other.args == self.args and other.body == self.body
        else:
            return False