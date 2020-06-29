%include "../../generator/asm2/raw/macro.asm"

global bytes_empty
global bytes_len
global bytes_raw_push
global bytes_raw_pop

section .text
bytes_empty:
    FUNCTION
    xor rdi, rdi
    mov si, 6
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    call memnew
    push rax
    RETURN

bytes_len:
    FUNCTION
    GET_LOCAL 0
    mov bl, [rax+8]
    INT rbx
    RETURN

bytes_raw_pop:
    FUNCTION
    GET_LOCAL 0
    mov rdi, rax
    call memclone
    push rax
    dec byte [rax+8]
    xor rbx, rbx
    mov bl, [rax+8]
    xor rcx, rcx
    mov cl, [rax+rbx+9]
    INT rcx
    RETURN

bytes_raw_push:
    FUNCTION
    GET_LOCAL 0
    mov rdi, rax
    call memclone
    push rax
    inc byte [rax+8]
    GET_LOCAL 1
    xor rcx, rcx
    mov cl, [rax+8]
    mov rax, [rsp]
    xor rbx, rbx
    mov bl, [rax+8]
    mov [rax+rbx+8], cl
    RETURN