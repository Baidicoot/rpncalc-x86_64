extern scopelen
extern scopemem

global memclear
global memalloc
global memdrop
global memext
global memunext

global get_local
global give_arg

section .text
; clears memory starting at scopemem length [scopelen]*4*8
; additionally uses registers r8, r9, r10
memclear:
    mov r8, scopelen
    mov r8, [r8]
    shl r8, 5
    mov r9, 0
.loop:
    cmp r8, r9
    je .exit
    mov r10, scopemem
    add r10, r9
    mov qword [r10], 0
    inc r9
    jmp .loop
.exit:
    ret

; allocates memory for a single block
; additionally uses registers r8, r9, r10
memalloc:
    mov r8, scopelen
    mov r8, [r8]
    shl r8, 5
    mov r9, 0
.loop:
    cmp r9, r8
    je .err
    mov r10, scopemem
    add r10, r9
    cmp qword [r10+8], 0
    je .ret
    add r9, 32
    jmp .loop
.ret:
    mov rax, scopemem
    add rax, r9
    ret
.err:
    mov rax, 0xdeaddead
    ret

; derefs memory
; no additional registers used
memdrop:
    sub rsp, 8
    dec qword [rdi+8]
    cmp qword [rdi+8], 0
    jne .ret
.rec:
    mov rdi, [rdi]
    cmp rdi, 0
    je .ret
    call memdrop
.ret:
    add rsp, 8
    ret

; extends memory
; additionally uses registers r8, r9, r10
memext:
    sub rsp, 8
    call memalloc
    mov qword [rax], rdi
    mov qword [rax+8], 1
    mov qword [rax+16], rsi
    mov qword [rax+24], rdx
    add rsp, 8
    ret

; concats memory
; no additional registers used
memcons:
    sub rsp, 8
    call memalloc
    mov qword [rax], rdi
    mov qword [rax+8], 1
    mov qword [rax+16], rsi
    mov qword [rax+24], rdx
    add rsp, 8
    cmp rdi, 0
    je .ret
.nz:
    inc qword [rdi+8]
.ret:
    ret

; un-extends memory
; no additional registers used
memunext:
    sub rsp, 8
    mov rax, [rdi]
    cmp rax, 0
    je .end
.nz:
    inc qword [rax+8]
.end:
    ; call memdrop ; this will definately cause a memory leak
    add rsp, 8
    ret

; gets local n in scope
; no additional registers used
get_local:
.loop:
    cmp rdi, 0
    je .ret
    mov rsi, qword [rsi]
    dec rdi
    jmp .loop
.ret:
    mov rdx, [rsi+16]
    mov rax, [rsi+24]
    ret

; apply an argument to a closure
; no additional registers used
give_arg:
    sub rsp, 8
    mov r11, rdi
    mov rdi, [rdi]
    call memcons
    mov rsi, rax
    call memalloc
    mov [rax], rsi
    mov r8, [r11+8]
    mov [rax+8], r8
    mov r8, [r11+16]
    mov [rax+16], r8
    mov r8, [r11+24]
    dec r8
    mov [rax+24], r8
    add rsp, 8
    ret