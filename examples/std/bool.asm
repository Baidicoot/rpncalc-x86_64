%include "../../generator/asm2/raw/macro.asm"

global bool_same
global bool_eq
global bool_true
global bool_false
global bool_if_else

section .text
bool_true:
    FUNCTION
    INT 0x1
    RETURN

bool_false:
    FUNCTION
    INT 0x0
    RETURN

bool_same:
    FUNCTION
    GET_LOCAL 0
    push rax
    GET_LOCAL 1
    mov rbx, rax
    pop rax
    cmp rax, rbx
    je .eq
.ne:
    INT 0x0
    jmp .end
.eq:
    INT 0x1
.end:
    RETURN

bool_if_else:
    FUNCTION
    GET_LOCAL 2
    cmp qword [rax+8], 0
    je .eq
.ne:
    PUSH_LOCAL 0
    jmp .end
.eq:
    PUSH_LOCAL 1
.end:
    RETURN

bool_eq:
    FUNCTION
    GET_LOCAL 0
    push rax
    GET_LOCAL 1
    mov rsi, rax
    pop rdi
    call cmpmem
    INT rax
    RETURN

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