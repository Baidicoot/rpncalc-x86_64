
%include "macro.asm"
%define BLOCKS 128

global scopemem
global scopelen
global _0

section .data
scopelen: dq BLOCKS

section .bss
scopemem: resq BLOCKS*4

section .text
_0:
    FUNCTION
    call _1
    DEFINE
    INT 1
    INT 2
    PUSH_LOCAL 0
    RESOLVE
    RETURN
_1:
    FUNCTION
    mov r11, _2
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 2, rsi
    RETURN
_2:
    FUNCTION
    PUSH_LOCAL 1
    RESOLVE
    PUSH_LOCAL 0
    RESOLVE
    RETURN