%include "macro.asm"

extern _0
global _start

section .data
hex: db "0123456789abcdef"

section .bss
buf: resb 16
heap: resb 32*32

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

; writes u16 to hex in rsi
wtoh:
    ; di - u16
    ; rsi - buf
    push rdi
    mov r11, 0
.loop:
    cmp r11, 2
    je .ret
    mov r8, 1
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

putw:
    ; rdi - int
    mov rsi, buf
    call wtoh

    mov rdi, buf
    mov rsi, 4
    call putstr
    ret

putblock:
    ; rdi - block

    cmp rdi, 0
    je .z

    push rdi
    mov di, [rdi+6]
    call putw
    mov rdi, 0x20
    call putchar
    pop rdi

    push rdi
    mov rdi, [rdi+8]
    call putint
    pop rdi

    ; push rdi
    ; mov rdi, [rdi+16]
    ; call putint
    ; pop rdi

    ; push rdi
    ; mov rdi, [rdi+24]
    ; call putint
    ; pop rdi
.z:
    ret

putll:
    cmp rdi, 0
    je .end
    
    push rdi
    mov rdi, 0x28
    call putchar
    mov rdi, [rsp]
    mov rdi, [rdi+16]
    call putblock
    mov rdi, 0x29
    call putchar
    mov rdi, 0x20
    call putchar
    pop rdi

    mov rdi, [rdi+8]
    call putll
.end:
    ret

_start:
    mov rsi, 0
    mov rdi, 0
    call _0

    call putll

    mov rdi, 0x0a
    call putchar

    mov rax, 60
    mov rdi, 0
    syscall