%include "../../generator/asm/raw/macro.asm"

global mutref_new
global mutref_set
global mutref_get

section .text
mutref_new:
    FUNCTION
    GET_LOCAL 0
    push rdx
    push rax
    call memalloc
    pop r9
    pop r8
    mov qword [rax], 0
    mov qword [rax+8], 1
    mov [rax+16], r8
    mov [rax+24], r9
    push rax
    mov rax, 0x0000000500000000
    push rax
    RETURN

mutref_set:
    FUNCTION
    GET_LOCAL 0
    push rdx
    GET_LOCAL 1
    mov r8, rdx
    mov r9, rax
    pop rax
    mov [rax+16], r8
    mov [rax+24], r9
    push rax
    mov rax, 0x0000000500000000
    push rax
    RETURN

mutref_get:
    FUNCTION
    GET_LOCAL 0
    push qword [rdx+16]
    push qword [rdx+24]
    RETURN