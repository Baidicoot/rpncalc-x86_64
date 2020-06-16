%include "macro.asm"
%define BLOCKS 2048

global scopelen
global scopemem

global testfn

section .data
scopelen: dq BLOCKS

section .bss
scopemem: resq BLOCKS*4

section .text
addfn:
    FUNCTION
    PUSH_LOCAL 0
    PUSH_LOCAL 1
    pop r8
    pop r8
    pop r9
    pop r9
    add r8, r9
    push r8
    sub rsp, 8
    mov dword [rsp+4], 0
    mov dword [rsp], 1
    RETURN

fn1:
    FUNCTION

    mov r11, addfn
    CLOSURE r11, 3, 0

    RETURN

testfn:
    FUNCTION

    INT 0xdeadbeef
    INT 0xdeadbeef

    mov rdi, LOCAL_RETURN
    mov rsi, LOCAL_SCOPE

    call fn1
    MERGE

    RETURN