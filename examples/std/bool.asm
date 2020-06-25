%include "../../generator/asm2/raw/macro.asm"

global bool_eq
global bool_true
global bool_false
global bool_if_else

section .text
bool_true:
    FUNCTION
    INT 0x1
    RETURN

bool_false:
    FUNCTION
    INT 0x0
    RETURN

bool_eq:
    FUNCTION
    GET_LOCAL 0
    push rax
    GET_LOCAL 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    je .eq
.ne:
    INT 0x0
    jmp .end
.eq:
    INT 0x1
.end:
    RETURN

bool_if_else:
    FUNCTION
    GET_LOCAL 2
    cmp qword [rax+8], 0
    je .eq
.ne:
    PUSH_LOCAL 0
    jmp .end
.eq:
    PUSH_LOCAL 1
.end:
    RETURN