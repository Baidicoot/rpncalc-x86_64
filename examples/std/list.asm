%include "../../generator/asm2/raw/macro.asm"

global list_cons
global list_nil
global list_is_nil
global list_uncons

section .text
list_cons:
    FUNCTION
    PUSH_LOCAL 0
    PUSH_LOCAL 1

    pop rbx
    pop rax
    xor rcx, rcx
    mov di, 0b110
    mov si, 3
    call memnew

    push rax

    RETURN

list_nil:
    FUNCTION
    xor rax, rax
    xor rbx, rbx
    xor rcx, rcx
    mov di, 0b00
    mov si, 3
    call memnew

    push rax
    RETURN

list_is_nil:
    FUNCTION
    GET_LOCAL 0
    cmp qword [rax+8], 0
    je .true
.false:
    INT 0x0
    jmp .ret
.true:
    INT 0x1
.ret:
    RETURN

list_uncons:
    FUNCTION
    GET_LOCAL 0
    push rax
    mov rdi, [rax+8]
    call memref
    pop rax
    push rdi
    mov rdi, [rax+16]
    call memref
    push rdi
    RETURN