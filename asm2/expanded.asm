; this is the input `(swap; a b -> b a) 1 2 swap` fully expanded, for reference
%line 1+1 test2.asm
%line 4+1 macro.asm
[extern memclear]
[extern memalloc]
[extern memdrop]
[extern memext]
[extern memunext]
[extern get_local]
[extern give_arg]
%line 21+1 macro.asm
%line 29+1 macro.asm
%line 39+1 macro.asm
%line 45+1 macro.asm
%line 51+1 macro.asm
%line 83+1 macro.asm
%line 94+1 macro.asm
%line 103+1 macro.asm
%line 108+1 macro.asm
%line 120+1 macro.asm
%line 127+1 macro.asm
%line 164+1 macro.asm
%line 212+1 macro.asm
%line 4+1 test2.asm
[global scopemem]
[global scopelen]
[global _0]
[section .data]
scopelen: dq 128
[section .bss]
scopemem: resq 128*4
[section .text]
_0:
    push rbp
%line 17+0 test2.asm
    mov rbp, rsp
    sub rsp, 16
    mov qword [rbp-8], rdi
    mov qword [rbp-16], rsi
%line 18+1 test2.asm
    call _1
%line 19+0 test2.asm
    mov rdi, [rbp-16]
    mov rsi, rax
    mov rdx, 0x0000000100000000
    call memext
    mov [rbp-16], rax
%line 20+1 test2.asm
    mov r8, 1
%line 20+0 test2.asm
    push r8
    mov r8, 0x0000000200000000
    push r8
%line 21+1 test2.asm
    mov r8, 2
%line 21+0 test2.asm
    push r8
    mov r8, 0x0000000200000000
    push r8
%line 22+1 test2.asm
%line 22+0 test2.asm
    mov rdi, 0
    mov rsi, qword [rbp-16]
    call get_local
    push rdx
    push rax
%line 23+1 test2.asm
%line 23+0 test2.asm
    cmp dword [rsp+4], 0
    je ..@18.closure
    cmp dword [rsp+4], 1
    je ..@18.list
    jmp ..@18.end
..@18.closure:
    cmp dword [rsp], 0
    jne ..@19.end
    add rsp, 8
    pop r9
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
..@19.apply:
    cmp qword [r9+24], 0
    je ..@19.exec
    cmp r8, 0
    je ..@19.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@19.apply
..@19.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    ..@21.merge:
    cmp rax, 0
    je ..@21.end
    cmp dword [rax+28], 0
    je ..@21.closure
..@21.value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp ..@21.merge
..@21.closure:
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov r9, [rax+16]
    mov rdi, rax
    call memunext
..@21.apply:
    cmp qword [r9+24], 0
    je ..@21.exec
    cmp r8, 0
    je ..@21.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@21.apply
..@21.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    jmp ..@21.merge
..@21.pushc:
    push r9
    mov r9, 0
    push r9
    jmp ..@21.merge
..@21.end:
    jmp ..@19.end
..@19.pushc:
    push r9
    mov r9, 0
    push r9
..@19.end:
    jmp ..@18.end
..@18.list:
    pop rax
    pop rax
    ..@23.merge:
    cmp rax, 0
    je ..@23.end
    cmp dword [rax+28], 0
    je ..@23.closure
..@23.value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp ..@23.merge
..@23.closure:
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov r9, [rax+16]
    mov rdi, rax
    call memunext
..@23.apply:
    cmp qword [r9+24], 0
    je ..@23.exec
    cmp r8, 0
    je ..@23.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@23.apply
..@23.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    jmp ..@23.merge
..@23.pushc:
    push r9
    mov r9, 0
    push r9
    jmp ..@23.merge
..@23.end:
    jmp ..@18.end
..@18.end:
%line 24+1 test2.asm
%line 24+0 test2.asm
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov rdi, [rbp-8]
..@25.loop:
    cmp r8, 0
    je ..@25.ret
    dec r8
    pop rdx
    pop rsi
    push r8
    sub rsp, 8
    call memext
    add rsp, 8
    pop r8
    mov rdi, rax
    jmp ..@25.loop
..@25.ret:
    add rsp, 16
    pop rbp
    mov rax, rdi
    ret
%line 25+1 test2.asm
_1:
    push rbp
%line 26+0 test2.asm
    mov rbp, rsp
    sub rsp, 16
    mov qword [rbp-8], rdi
    mov qword [rbp-16], rsi
%line 27+1 test2.asm
    mov r11, _2
    mov rsi, [rbp-16]
    call memalloc
%line 29+0 test2.asm
    mov qword [rax], rsi
    mov qword [rax+8], 1
    mov qword [rax+16], r11
    mov dword [rax+24], 2
    mov dword [rax+28], 0
    push rax
    mov rax, 0
    push rax
%line 30+1 test2.asm
%line 30+0 test2.asm
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov rdi, [rbp-8]
..@29.loop:
    cmp r8, 0
    je ..@29.ret
    dec r8
    pop rdx
    pop rsi
    push r8
    sub rsp, 8
    call memext
    add rsp, 8
    pop r8
    mov rdi, rax
    jmp ..@29.loop
..@29.ret:
    add rsp, 16
    pop rbp
    mov rax, rdi
    ret
%line 31+1 test2.asm
_2:
    push rbp
%line 32+0 test2.asm
    mov rbp, rsp
    sub rsp, 16
    mov qword [rbp-8], rdi
    mov qword [rbp-16], rsi
%line 33+1 test2.asm
%line 33+0 test2.asm
    mov rdi, 1
    mov rsi, qword [rbp-16]
    call get_local
    push rdx
    push rax
%line 34+1 test2.asm
%line 34+0 test2.asm
    cmp dword [rsp+4], 0
    je ..@33.closure
    cmp dword [rsp+4], 1
    je ..@33.list
    jmp ..@33.end
..@33.closure:
    cmp dword [rsp], 0
    jne ..@34.end
    add rsp, 8
    pop r9
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
..@34.apply:
    cmp qword [r9+24], 0
    je ..@34.exec
    cmp r8, 0
    je ..@34.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@34.apply
..@34.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    ..@36.merge:
    cmp rax, 0
    je ..@36.end
    cmp dword [rax+28], 0
    je ..@36.closure
..@36.value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp ..@36.merge
..@36.closure:
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov r9, [rax+16]
    mov rdi, rax
    call memunext
..@36.apply:
    cmp qword [r9+24], 0
    je ..@36.exec
    cmp r8, 0
    je ..@36.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@36.apply
..@36.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    jmp ..@36.merge
..@36.pushc:
    push r9
    mov r9, 0
    push r9
    jmp ..@36.merge
..@36.end:
    jmp ..@34.end
..@34.pushc:
    push r9
    mov r9, 0
    push r9
..@34.end:
    jmp ..@33.end
..@33.list:
    pop rax
    pop rax
    ..@38.merge:
    cmp rax, 0
    je ..@38.end
    cmp dword [rax+28], 0
    je ..@38.closure
..@38.value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp ..@38.merge
..@38.closure:
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov r9, [rax+16]
    mov rdi, rax
    call memunext
..@38.apply:
    cmp qword [r9+24], 0
    je ..@38.exec
    cmp r8, 0
    je ..@38.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@38.apply
..@38.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    jmp ..@38.merge
..@38.pushc:
    push r9
    mov r9, 0
    push r9
    jmp ..@38.merge
..@38.end:
    jmp ..@33.end
..@33.end:
%line 35+1 test2.asm
%line 35+0 test2.asm
    mov rdi, 0
    mov rsi, qword [rbp-16]
    call get_local
    push rdx
    push rax
%line 36+1 test2.asm
%line 36+0 test2.asm
    cmp dword [rsp+4], 0
    je ..@41.closure
    cmp dword [rsp+4], 1
    je ..@41.list
    jmp ..@41.end
..@41.closure:
    cmp dword [rsp], 0
    jne ..@42.end
    add rsp, 8
    pop r9
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
..@42.apply:
    cmp qword [r9+24], 0
    je ..@42.exec
    cmp r8, 0
    je ..@42.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@42.apply
..@42.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    ..@44.merge:
    cmp rax, 0
    je ..@44.end
    cmp dword [rax+28], 0
    je ..@44.closure
..@44.value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp ..@44.merge
..@44.closure:
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov r9, [rax+16]
    mov rdi, rax
    call memunext
..@44.apply:
    cmp qword [r9+24], 0
    je ..@44.exec
    cmp r8, 0
    je ..@44.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@44.apply
..@44.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    jmp ..@44.merge
..@44.pushc:
    push r9
    mov r9, 0
    push r9
    jmp ..@44.merge
..@44.end:
    jmp ..@42.end
..@42.pushc:
    push r9
    mov r9, 0
    push r9
..@42.end:
    jmp ..@41.end
..@41.list:
    pop rax
    pop rax
    ..@46.merge:
    cmp rax, 0
    je ..@46.end
    cmp dword [rax+28], 0
    je ..@46.closure
..@46.value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp ..@46.merge
..@46.closure:
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov r9, [rax+16]
    mov rdi, rax
    call memunext
..@46.apply:
    cmp qword [r9+24], 0
    je ..@46.exec
    cmp r8, 0
    je ..@46.pushc
    dec r8
    mov rdi, r9
    pop rdx
    pop rsi
    push r8
    push rax
    call give_arg
    mov r9, rax
    pop rax
    pop r8
    jmp ..@46.apply
..@46.exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    jmp ..@46.merge
..@46.pushc:
    push r9
    mov r9, 0
    push r9
    jmp ..@46.merge
..@46.end:
    jmp ..@41.end
..@41.end:
%line 37+1 test2.asm
%line 37+0 test2.asm
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4
    mov rdi, [rbp-8]
..@48.loop:
    cmp r8, 0
    je ..@48.ret
    dec r8
    pop rdx
    pop rsi
    push r8
    sub rsp, 8
    call memext
    add rsp, 8
    pop r8
    mov rdi, rax
    jmp ..@48.loop
..@48.ret:
    add rsp, 16
    pop rbp
    mov rax, rdi
    ret