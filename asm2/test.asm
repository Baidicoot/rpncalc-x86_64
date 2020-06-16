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
    mov r8, INT_TYPE
    push r8
    RETURN

fn1:
    FUNCTION

    INT 0x1

    mov r11, addfn
    CLOSURE r11, 2, 0

    RETURN

testf:
    FUNCTION

    INT 0xdeadbeef
    INT 0xcafebabe

    mov rdi, LOCAL_RETURN
    mov rsi, LOCAL_SCOPE

    call fn1
    MERGE

    RETURN

testfn:
    FUNCTION

    INT 0x1

    mov r11, addfn
    CLOSURE r11, 2, 0
    APPLY

    RETURN