section .data
hex: db "0123456789abcdef"
block: db "BLOCK at "
blocklen: dq blocklen-block
nl: db 0x0A

section .bss
buf: resb 16

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

    mov rax, 1
    mov rdi, 1
    mov rsi, nl
    mov rdx, 1
    syscall

    ret

printblock:
    ; rdi - blockptr
    push rdi
    mov rsi, buf
    call itoh

    mov rdi, block
    mov rsi, [blocklen]
    call putstr

    mov rdi, buf
    mov rsi, 16
    call putstrln

    pop rdi
    ret


_start:
    mov rdi, 0xdeadbeefcafebabe
    call printblock

    mov rax, 60
    mov rdi, 0
    syscall