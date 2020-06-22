%include "../generator/asm/raw/macro.asm"

global bool_eq
global bool_true
global bool_false
global bool_if_else

section .text
bool_true:
    FUNCTION
    push 0x1
    mov rax, 0x0000000400000000
    push rax
    RETURN

bool_false:
    FUNCTION
    push 0x0
    mov rax, 0x0000000400000000
    push rax
    RETURN

bool_eq:
    FUNCTION
    GET_LOCAL 0
    push rdx
    push rax
    GET_LOCAL 1
    cmp [rsp+8], rdx
    jne .false
    cmp [rsp], rax
    jne .false
.true:
    mov qword [rsp+8], 0x1
    jmp .ret
.false:
    mov qword [rsp+8], 0x0
.ret:
    mov rax, 0x0000000400000000
    mov qword [rsp], rax
    RETURN

bool_if_else:
    FUNCTION
    GET_LOCAL 2
    cmp rdx, 0
    je .eq
.ne:
    PUSH_LOCAL 0
    jmp .ret
.eq:
    PUSH_LOCAL 1
.ret:
    RETURN