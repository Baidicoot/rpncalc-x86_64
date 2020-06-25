%include "macro.asm"

global heaploc
global heapsize
global _start

section .data
hex: db "0123456789abcdef"
heaploc: dq heap
heapsize: dq 4096*32

section .bss
buf: resb 16
heap: resb 4096*32

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

    push rdi
    mov rdi, [rdi+16]
    call putint
    pop rdi

    push rdi
    mov rdi, [rdi+24]
    call putint
    pop rdi
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

cmpmeta:
    ; rdi - dataX
    ; rsi - dataY
    push rsi
    call getmeta
    pop rsi
    push rbx
    push rcx
    mov rdi, rsi
    call getmeta

    pop rax
    cmp rcx, rax
    jne .ne
    pop rax
    cmp rbx, rax
    jne .ne
.eq:
    mov rax, 1
    ret
.ne:
    mov rax, 0
    ret

cmpdata:
    ; rdi - dataX
    ; rsi - dataY
    ; rax - mem flag
    cmp rdi, rsi
    je .eq
    cmp rax, 0
    je .ne
    call cmpmem
    ret
.eq:
    mov rax, 1
    ret
.ne:
    mov rax, 0
    ret

cmpmem:
    ; rdi - X
    ; rsi - Y
    push rdi
    push rsi
    call cmpmeta
    pop rdi
    pop rsi
    cmp rax, 0
    je .ne

    push rdi
    push rsi
    call getmeta
    pop rsi
    pop rdi
.d0:
    mov rax, rbx
    and rax, 0b100
    push rbx
    push rdi
    push rsi
    mov rdi, [rdi+8]
    mov rsi, [rsi+8]
    call cmpdata
    pop rsi
    pop rdi
    pop rbx
    cmp rax, 0
    je .ne
.d1:
    mov rax, rbx
    and rax, 0b010
    push rbx
    push rdi
    push rsi
    mov rdi, [rdi+16]
    mov rsi, [rsi+16]
    call cmpdata
    pop rsi
    pop rdi
    pop rbx
    cmp rax, 0
    je .ne
.d2:
    mov rax, rbx
    and rax, 0b001
    push rbx
    push rdi
    push rsi
    mov rdi, [rdi+24]
    mov rsi, [rsi+24]
    call cmpdata
    pop rsi
    pop rdi
    pop rbx
    cmp rax, 0
    je .ne
.eq:
    mov rax, 1
    ret
.ne:
    mov rax, 0
    ret

_start:
    INT 0xdeaf
    INT 0xdead
    pop rdi
    pop rsi

    call cmpmem

    mov rdi, rax
    call putint

    mov rax, 60
    mov rdi, 0
    syscall