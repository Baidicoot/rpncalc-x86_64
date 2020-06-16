from enum import Enum

"""
IR for RPNCalcV4:

operations:
push_local(n) - push nth local
define(f) - call f and bind
apply - call top stack element and merge
call(f) - call f and merge
ret - normal return
closure(f, n) - create a closure around the function f with n arguments
bytes(d) - push 32-bit data to the stack

for example:
(swap; a b -> b a) 1 2 swap
would become:

main:
    define(swap)
    bytes(1)
    bytes(2)
    push_local(0)
    apply
swap:
    closure(lambda0, 2)
    ret
lambda0:
    push_local(1)
    apply
    push_local(0)
    apply
    ret

REGISTER USAGE:
rbp points to the return address of the function
rbp+1 is the current scope pointer
rsp points to the top of the stack
"""

builtins = ["+", "-", "*", "/"]

class Addr:
    pass

class Rec(Addr):
    def __init__(self, i):
        self.index = i

class Bound(Addr):
    def __init__(self, i):
        self.index = i

# it is utterly stupid to use classes for this enum, but so is 'pythonic' python, so...
class Op:
    pass

class Apply(Op):
    def __init__(self):
        pass

    def emit(self):
        return """
    MERGE"""
    
    def __repr__(self):
        return "Apply"

class Local(Op):
    def __init__(self, index: int):
        self.index = index

    def emit(self):
        return """
    PUSH_LOCAL """ + str(self.index)
    
    def __repr__(self):
        return "Local(" + str(self.index) + ")"

class Call(Op):
    def __init__(self, index: int):
        self.index = index
    
    def emit(self):
        return """
    call _""" + str(self.index)
    
    def __repr__(self):
        return "Call(" + str(self.index) + ")"

class Ret(Op):
    def __init__(self):
        pass
    
    def emit(self):
        return """
    RETURN"""
    
    def __repr__(self):
        return "Ret"

class Define(Op):
    def __init__(self, index: int):
        self.index = index

    def emit(self):
        return """
    call _""" + str(self.index) + """
    DEFINE"""
    
    def __repr__(self):
        return "Define(" + str(self.index) + ")"

class Closure(Op):
    def __init__(self, index, nargs):
        self.index = index
        self.nargs = nargs
    
    def emit(self):
        return ""
    
    def __repr__(self):
        return "Closure(" + str(self.index) + "," + str(self.nargs) + ")"
    
class Bytes(Op):
    def __init__(self, data):
        self.data = data
    
    def emit(self):
        return """
    mov rax, """ + str(self.data) + """
    push rax
    mov rax, 0
    push rax"""
    
    def __repr__(self):
        return "Bytes"