%include "../../generator/asm2/raw/macro.asm"

global mutref_new
global mutref_set
global mutref_get

section .text
mutref_new:
    FUNCTION
    PUSH_LOCAL 0
    pop rax
    xor rbx, rbx
    xor rcx, rcx
    mov di, 0b100
    mov si, 5
    call memnew
    push rax
    RETURN

mutref_set:
    FUNCTION
    PUSH_LOCAL 0
    mov rdi, [rsp]
    mov rdi, [rdi+8]
    call memdrop
    PUSH_LOCAL 1
    pop rax
    mov rdi, [rsp]
    mov [rdi+8], rax
    RETURN

mutref_get:
    FUNCTION
    GET_LOCAL 0
    mov rdi, [rax+8]
    push rdi
    call memref
    RETURN