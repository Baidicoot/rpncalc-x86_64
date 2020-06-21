%include "../generator/asm/raw/macro.asm"

global list_cons
global list_nil

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