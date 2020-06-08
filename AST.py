from typing import List

"""
data Stmt -- 'MaybePush' would be clearer?
    = Push Expr
    | SingleExpr Expr

data Expr
    = Definition str [Stmt]
    | Int int
    | Str str
    | Lambda [str] [Stmt]
"""

# abstract class declarations:
class Stmt:
    pass

class Expr:
    pass

# case class definitions:
class Push(Stmt):
    def __init__(self, expr: Expr):
        self.elem = expr
    
    def __repr__(self):
        return "Push(" + repr(self.elem) + ")"

class SingleExpr(Stmt):
    def __init__(self, expr: Expr):
        self.expr = expr
    
    def __repr__(self):
        return "SExpr(" + repr(self.expr) + ")"

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