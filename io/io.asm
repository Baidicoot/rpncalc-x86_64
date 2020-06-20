%include "../generator/asm/raw/macro.asm"

section .data
hex: db "0123456789abcdef"

typenames: dq clstype, listype, inttype
typelens: dq 11, 8, 7
typeprints: dq printcls, printlist, printint

inttype: db "INT at "
clstype: db "CLOSURE at "
listype: db "LIST at "

refstr: db " objects reference this"
reflen: dq reflen-refstr

himsg: db "hi!", 0xA

scopemsg: db "scope: "
scopelen: dq scopelen-scopemsg

section .bss
buf: resb 16

global io_printscope
global io_sayhi
global io_putchar
global io_putint
global io_putbyte

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

indent:
    cmp rdi, 0
    je .exit
    push rdi

    mov rdi, 0x20
    call putchar
    pop rdi
    dec rdi
    jmp indent
.exit:
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

newline:
    mov rdi, 0xA
    call putchar
    ret

printblock:
    push rdi
    push rsi
    ; rdi - blockptr
    ; rsi - indent
    cmp rdi, 0
    je .exit

    mov rdi, [rsp]
    call indent

    mov rdi, [rsp+8]
    mov r8, 0
    mov r8d, [rdi+28]
    shl r8, 3
    mov rdi, typenames
    mov rdi, [rdi+r8]
    mov rsi, typelens
    mov rsi, [rsi+r8]
    call putstr

    mov rdi, [rsp+8]
    call putint

    call newline

    add qword [rsp], 4

    mov rdi, [rsp]
    call indent

    mov rdi, [rsp+8]
    mov rdi, [rdi+8]
    call putint

    mov rdi, refstr
    mov rsi, reflen
    mov rsi, [rsi]
    call putstrln

    mov rdi, [rsp+8]
    mov r8, 0
    mov r8d, [rdi+28]
    shl r8, 3
    mov r9, typeprints
    mov rdi, [rsp+8]
    mov rsi, [rsp]
    call [r9+r8]

    mov rdi, [rsp+8]
    mov rdi, [rdi]
    mov rsi, [rsp]
    call printblock
.exit:
    pop rsi
    pop rdi
    ret

printint:
    push rdi
    mov rdi, rsi
    call indent
    pop rdi

    mov rdi, [rdi+16]
    mov rsi, buf
    call itoh

    mov rdi, buf
    mov rsi, 16
    call putstrln

    ret

printcls:
    mov rdi, [rdi+16]
    push rdi
    push rsi

    mov rdi, [rsp]
    call indent

    mov rdi, [rsp+8]
    mov rdi, [rdi+24]
    call putint

    call newline

    mov rdi, [rsp]
    call indent

    mov rdi, [rsp+8]
    mov rdi, [rdi+16]
    call putint

    call newline

    mov rdi, [rsp+8]
    mov rdi, [rdi]
    ; mov rdi, [rdi]
    mov rsi, [rsp]
    call printblock

    pop rsi
    pop rdi
    ret

printlist:
    mov rdi, [rdi+16]
    call printblock
    ret

io_printscope:
    FUNCTION
    mov rdi, scopemsg
    mov rsi, scopelen
    mov rsi, [rsi]
    call putstrln

    mov rdi, LOCAL_SCOPE
    mov rsi, 0
    call printblock
    RETURN

io_putchar:
    FUNCTION
    GET_LOCAL 0
    mov rdi, rdx
    call putchar
    RETURN

io_sayhi:
    mov rdi, himsg
    mov rsi, 4
    call putstr
    mov rax, 0
    ret

io_putbyte:
    FUNCTION
    GET_LOCAL 0
    mov rdi, rdx
    call mkbyte
    push rax
    mov rdi, rsp
    mov rsi, 2
    call putstr
    pop rax
    RETURN

io_putint:
    FUNCTION
    GET_LOCAL 0
    mov rdi, rdx
    call putint
    RETURN