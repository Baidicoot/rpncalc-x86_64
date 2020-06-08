from enum import Enum

"""
IR for RPNCalcV4:

special operations:
bind - binds the top item on the stack to a local variable
bind_frame - binds the current frame to a local variable in the parent frame
call_local(x) - calls the xth local variable (debrujin indexes)
push_local(x) - pushes the xth local variable
merge - performs a stack merge
frame - opens a new stack frame
call_builtin(index) - call a builtin function

{} denote blocks

for example:
(swap; a b -> b a) 1 2 swap
would become:
frame {frame {call_local(0) call_local(1) merge} bind_frame} 1 2 bind bind call_local(2)
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

class Bind(Op):
    def __init__(self):
        pass

    def emit(self):
        return ""

class BindFrame(Op):
    def __init__(self):
        pass

    def emit(self):
        return ""

class CallLocal(Op):
    def __init__(self, index: int):
        self.index = index

    def emit(self):
        return ""

class PushLocal(Op):
    def __init__(self, index: int):
        self.index = index

    def emit(self):
        return ""

class Merge(Op):
    def __init__(self):
        pass

    def emit(self):
        return ""

class Frame(Op):
    def __init__(self):
        pass

    def emit(self):
        return ""

class Goto(Op):
    def __init__(self, index):
        self.index = index
    
    def emit(self):
        return ""
    
class Bytes(Op):
    def __init__(self, data: bytes):
        self.data = data
    
    def emit(self):
        return ""