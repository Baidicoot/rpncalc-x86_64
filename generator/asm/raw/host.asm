%include "raw/macro.asm"

section .data
hex: db "0123456789abcdef"
closure: db "(closure; needs "
closurelen: dq closurelen-closure
list: db "list"
listlen: dq listlen-list

section .bss
buf: resb 16

extern _0
global _start

section .text
; converts byte to 2-digit hex (in ax)
mkbyte:
    ; dil - byte
    mov r8, 0
    mov r9, 0
    mov r8b, dil
    mov r9b, dil
    and r8b, 0b11110000
    and r9b, 0b00001111
    shr r8b, 4
    mov r10, hex
    mov r8b, [r10+r8]
    mov r9b, [r10+r9]
    shl r9, 8
    or r8, r9
    mov ax, r8w
    ret

; writes u64 in hex to rsi
itoh:
    ; rdi - u64
    ; rsi - buf
    push rdi
    mov r11, 0
.loop:
    cmp r11, 8
    je .ret
    mov r8, 7
    sub r8, r11
    mov dil, [rsp+r8]
    call mkbyte
    mov [rsi+(r11*2)], ax
    inc r11
    jmp .loop
.ret:
    pop rdi
    mov rax, rdi
    ret

putchar:
    ; dil - char
    push rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rdi
    ret

putstr:
    ; rdi - buf
    ; rsi - buflen
    mov rax, 1
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1
    syscall
    ret

putstrln:
    ; rdi - buf
    ; rsi - buflen
    mov rax, 1
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1
    syscall

    mov rdi, 0xA
    call putchar

    ret

putint:
    ; rdi - int
    ; uses rsi
    mov rsi, buf
    call itoh

    mov rdi, buf
    mov rsi, 16
    call putstr
    ret

printblock:
    push rdi
    cmp rdi, 0
    je .ret
    mov r9d, [rdi+28]
    cmp r9d, 0
    je .closure
    cmp r9d, 1
    je .list
    cmp r9d, 2
    je .int
.other:
    mov rdi, 0x28
    call putchar

    mov rdi, [rsp]
    mov rdi, [rdi+16]
    call putint

    mov rdi, 0x20
    call putchar

    mov rdi, [rsp]
    mov rdi, [rdi+24]
    call putint

    mov rdi, 0x29
    call putchar

    jmp .rep
.closure:
    mov rdi, closure
    mov rsi, closurelen
    mov rsi, [rsi]
    call putstr

    mov rdi, [rsp]
    mov rdi, [rdi+16]
    mov rdi, [rdi+24]
    call putint

    mov rdi, 0x29
    call putchar

    jmp .rep
.list:
    mov rdi, list
    mov rsi, listlen
    mov rsi, [rsi]
    call putstr

    jmp .rep
.int:
    mov rdi, [rsp]
    mov rdi, [rdi+16]
    call putint

    jmp .rep
.rep:
    mov rdi, 0x20
    call putchar

    pop rdi
    mov rdi, [rdi]
    jmp printblock
.ret:
    pop rdi
    ret

_start:
    mov rdi, 0
    mov rsi, 0
    call _0

    mov rdi, rax
    mov rsi, 0
    call printblock

    mov rdi, 0x0A
    call putchar

    mov rax, 60
    mov rdi, 0
    syscall