%include "../../generator/asm2/raw/macro.asm"

global debug_obj
global debug_mem

extern heaploc
extern heapsize
extern putint

section .text
d_putblock:
    ; rdi - block

    push rdi
    call putint
    mov rdi, 0x20
    call putchar
    pop rdi

    cmp rdi, 0
    je .z

    push rdi
    mov rdi, [rdi]
    call putint
    mov rdi, 0x20
    call putchar
    pop rdi

    push rdi
    mov rdi, [rdi+8]
    call putint
    pop rdi

    push rdi
    mov rdi, [rdi+16]
    call putint
    pop rdi

    push rdi
    mov rdi, [rdi+24]
    call putint
    pop rdi
.z:
    push rdi
    mov rdi, 0x0a
    call putchar
    pop rdi

    ret

debug_obj:
    FUNCTION
    GET_LOCAL 0
    mov rdi, rax
    call d_putblock
    RETURN

debug_mem:
    FUNCTION
    mov rdi, [heaploc]
    jmp .loop
.next:
    add rdi, 32
.loop:
    mov rsi, [heaploc]
    add rsi, [heapsize]
    cmp rdi, rsi
    je .end
    push rdi
    call d_putblock
    pop rdi
    jmp .next
.end:
    RETURN