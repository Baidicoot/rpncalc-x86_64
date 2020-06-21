from parser.AST import *
from generator.asm.IR import *
from typing import List, Tuple, Dict, TypeVar, Generic

T = TypeVar('T')
class Maybe(Generic[T]):
    def __init__(self, val: T):
        self.val: T = val
        self.isNothing = val == None
    
    def unwrap(self, msg='unwrap ERROR: cannot unwrap a Nothing value') -> T:
        if (self.val == None):
            raise BaseException(msg)
        else:
            return self.val

def Nothing() -> Maybe[T]:
        return Maybe(None)
    
def Just(val: T) -> Maybe[T]:
    return Maybe(val)

class Walker:
    def __init__(self, bound: List[Tuple[Maybe[str], int, List[str]]], completed: List[Maybe[List[Op]]], current: List[List[Op]], indexes: List[int], extern: Dict[str, Tuple[str, int]]):
        self.bound = bound
        self.completed = completed
        self.current = current
        self.indexes = indexes
        self.extern = extern
    
    def bind(self, name: str) -> 'Walker':
        bname, index, idents = self.bound[0]
        bound = [(bname, index, [name] + idents)] + self.bound[1:]
        return Walker(bound, self.completed, self.current, self.indexes, self.extern)

    def newindex(self) -> int:
        return len(self.completed)
    
    def make_block(self, name: Maybe[str] = Nothing(), args: List[str] = []) -> 'Walker':
        newindex = self.newindex()
        indexes = [newindex] + self.indexes
        completed = self.completed + [Nothing()]
        current = [[]] + self.current
        bound = [(name, newindex, args)] + self.bound
        return Walker(bound, completed, current, indexes, self.extern)

    def write(self, ins: List[Op]) -> 'Walker':
        current = [self.current[0] + ins] + self.current[1:]
        return Walker(self.bound, self.completed, current, self.indexes, self.extern)
    
    def end_block(self) -> 'Walker':
        indexes = self.indexes[1:]
        current = self.current[1:]
        completed = self.completed[:]
        completed[self.indexes[0]] = Just(self.current[0])
        bound = self.bound[1:]
        return Walker(bound, completed, current, indexes, self.extern)
    
    def name_block(self) -> 'Walker':
        return self.end_block().bind(self.bound[0][0].unwrap())
    
    def index(self, name: str) -> Maybe[Addr]:
        count = 0
        for ident, _, scope in self.bound:
            if not ident.isNothing:
                if ident.unwrap() == name:
                    return Just(Rec(count))
            for s in scope:
                if s == name:
                    return Just(Bound(count))
                else:
                    count += 1
        return Nothing()
    
    def get_extern(self, name: str) -> Maybe[Tuple[str, int]]:
        return Maybe(self.extern.get(name))
    
    def finish(self) -> List[List[Op]]:
        ctx = self.end_block()
        out = []
        for c in ctx.completed:
            out.append(c.unwrap())
        return out

def desugar(ctx: Walker, s: Stmt) -> Walker:
    c = s.__class__
    if c == Push:
        e = s.elem
        c = s.elem.__class__
        if c == Ident:
            a = ctx.index(e.name)
            if a.isNothing:
                a = ctx.get_extern(e.name)
                if a.isNothing:
                    raise BaseException('variable ' + e.name + ' not in scope')
                else:
                    ext = a.unwrap()
                    return ctx.write([Builtin(ext[0], ext[1])])
            addr = a.unwrap()
            if addr.__class__ == Rec:
                return ctx.write([Closure(addr.index, 0)])
            elif addr.__class__ == Bound:
                return ctx.write([Local(addr.index)])
        elif c == Lambda:
            index = ctx.newindex()
            ctx = ctx.make_block(name=Nothing(), args=e.args)
            for stmt in e.body:
                ctx = desugar(ctx, stmt)
            ctx = ctx.write([Ret()]).end_block()
            return ctx.write([Closure(index, len(e.args))])
        else:
            return ctx.write([literal(e)])
    elif c == SingleExpr:
        e = s.elem
        c = s.elem.__class__
        if c == Ident:
            a = ctx.index(e.name)
            if a.isNothing:
                a = ctx.get_extern(e.name)
                if a.isNothing:
                    raise BaseException('variable ' + e.name + ' not in scope')
                else:
                    ext = a.unwrap()
                    return ctx.write([Builtin(ext[0], ext[1]), Apply()])
            addr = a.unwrap()
            if addr.__class__ == Rec:
                return ctx.write([Call(addr.index)])
            elif addr.__class__ == Bound:
                return ctx.write([Local(addr.index), Apply()])
        elif c == Lambda:
            index = ctx.newindex()
            ctx = ctx.make_block(name=Nothing(), args=e.args)
            for stmt in e.body:
                ctx = desugar(ctx, stmt)
            ctx = ctx.write([Ret()]).end_block()
            return ctx.write([Closure(index, len(e.args)), Apply()])
        else:
            return ctx.write([literal(e)])
    elif c == Definition:
        index = ctx.newindex()
        ctx = ctx.make_block(name=Just(s.ident))
        for stmt in s.body:
            ctx = desugar(ctx, stmt)
        ctx = ctx.write([Ret()]).name_block()
        return ctx.write([Define(index)])

def literal(e):
    return Bytes(e.val)

def irify(stmts: List[Stmt], extern: Dict[str, Tuple[str, int]], length=False):
    ctx = Walker([(Nothing(), 0, [])], [Nothing()], [[]], [0], extern)
    for s in stmts:
        ctx = desugar(ctx, s)
    if length:
        return (ctx.finish(), ctx.newindex())
    else:
        return ctx.finish()