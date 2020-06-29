%include "../../generator/asm2/raw/macro.asm"

global arith_add
global arith_sub
global arith_mul
global arith_div
global arith_gt

section .text:
arith_add:
    FUNCTION
    GET_LOCAL 0
    push qword [rax+8]
    GET_LOCAL 1
    pop rbx
    add rbx, [rax+8]
    INT rbx
    RETURN

arith_sub:
    FUNCTION
    GET_LOCAL 0
    push qword [rax+8]
    GET_LOCAL 1
    pop rbx
    sub rbx, [rax+8]
    INT rbx
    RETURN

arith_mul:
    FUNCTION
    GET_LOCAL 0
    push qword [rax+8]
    GET_LOCAL 1
    pop rdi
    mov rax, [rax+8]
    mul rdi
    INT rax
    RETURN

arith_div:
    FUNCTION
    GET_LOCAL 1
    push qword [rax+8]
    GET_LOCAL 0
    xor rdx, rdx
    pop rbx
    mov rax, [rax+8]
    idiv rbx
    INT rax
    RETURN
    
arith_gt:
    FUNCTION
    GET_LOCAL 0
    push qword [rax+8]
    GET_LOCAL 1
    mov rbx, [rax+8]
    pop rax
    cmp rax, rbx
    jg .gt
.le:
    INT 0
    jmp .end
.gt:
    INT 1
.end:
    RETURN