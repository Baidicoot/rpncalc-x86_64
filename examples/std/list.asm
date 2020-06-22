%include "../../generator/asm/raw/macro.asm"

global list_cons
global list_nil
global list_is_nil
global list_uncons

section .text
list_cons:
    FUNCTION
    GET_LOCAL 0
    push rdx
    push rax
    call memalloc
    mov qword [rax], 0
    mov qword [rax+8], 1
    pop r8
    mov [rax+16], r8
    pop r8
    mov [rax+24], r8
    push rax

    GET_LOCAL 1
    push rdx
    push rax
    call memalloc
    mov qword [rax], 0
    mov qword [rax+8], 1
    pop r8
    mov [rax+16], r8
    pop r8
    mov [rax+24], r8
    push rax

    call memalloc
    mov qword [rax], 0
    mov qword [rax+8], 1
    pop r8
    mov [rax+16], r8
    pop r8
    mov [rax+24], r8
    
    push rax
    mov rax, 0x0000000300000000
    push rax

    RETURN

list_nil:
    FUNCTION
    push 0
    mov rax, 0x0000000300000000
    push rax
    RETURN

list_is_nil:
    FUNCTION
    GET_LOCAL 0
    cmp rdx, 0
    je .true
.false:
    push 0x0
    mov rax, 0x0000000400000000
    push rax
    jmp .ret
.true:
    push 0x1
    mov rax, 0x0000000400000000
    push rax
.ret:
    RETURN

list_uncons:
    FUNCTION
    GET_LOCAL 0
    mov r8, [rdx+24]
    mov r9, [r8+16]
    mov r10, [r8+24]
    push r10
    push r9
    mov r8, [rdx+16]
    mov r9, [r8+16]
    mov r10, [r8+24]
    push r10
    push r9
    RETURN