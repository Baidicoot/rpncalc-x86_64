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

builtins = {
    "io.printscope": ("io_printscope", 0),
    "io.sayhi": ("io_sayhi", 0),
    "io.putchar": ("io_putchar", 1),
    "io.putint": ("io_putint", 1),
    "io.putbyte": ("io_putbyte", 1),
}

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

class Builtin(Op):
    def __init__(self, name, nargs):
        self.name = name
        self.nargs = nargs
    
    def emit(self, offset=0):
        return """
    mov r11, """ + self.name + """
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, """ + str(self.nargs) + ", rsi"

class Apply(Op):
    def __init__(self):
        pass

    def emit(self, offset=0):
        return """
    RESOLVE"""
    
    def __repr__(self):
        return "Apply"

class Local(Op):
    def __init__(self, index: int):
        self.index = index

    def emit(self, offset=0):
        return """
    PUSH_LOCAL """ + str(self.index)
    
    def __repr__(self):
        return "Local(" + str(self.index) + ")"

class Call(Op):
    def __init__(self, index: int):
        self.index = index
    
    def emit(self, offset=0):
        return """
    INITCALL
    call _""" + str(self.index+offset)
    
    def __repr__(self):
        return "Call(" + str(self.index) + ")"

class Ret(Op):
    def __init__(self):
        pass
    
    def emit(self, offset=0):
        return """
    RETURN"""
    
    def __repr__(self):
        return "Ret"

class Define(Op):
    def __init__(self, index: int):
        self.index = index

    def emit(self, offset=0):
        return """
    INITCALL
    call _""" + str(self.index+offset) + """
    DEFINE"""
    
    def __repr__(self):
        return "Define(" + str(self.index) + ")"

class Closure(Op):
    def __init__(self, index, nargs):
        self.index = index
        self.nargs = nargs
    
    def emit(self, offset=0):
        return """
    mov r11, _""" + str(self.index+offset) + """
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, """ + str(self.nargs) + ", rsi"
    
    def __repr__(self):
        return "Closure(" + str(self.index) + "," + str(self.nargs) + ")"
    
class Bytes(Op):
    def __init__(self, data):
        self.data = data
        if self.data is str:
            print("WARNING: STRING DATA NOT SUPPORTED!")
    
    def emit(self, offset=0):
        return """
    INT """ + str(self.data)
    
    def __repr__(self):
        return "Bytes"