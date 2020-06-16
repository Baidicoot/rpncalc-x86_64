%define LOCAL_SCOPE [rbp-16]
%define LOCAL_RETURN [rbp-8]
%define INT_TYPE 0x0000000200000000

extern memclear
extern memalloc
extern memdrop
extern memext
extern memunext

extern get_local
extern give_arg

%macro FUNCTION 0
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov qword [rbp-8], rdi
    mov qword [rbp-16], rsi
%endmacro

%macro GET_NELEMS 0
    ; calculate number of elements on the stack (REQUIRES rbp TO BE SET)
    ; discount two qwords on stack as they are [return stack] and [scope pointer]
    lea r8, [rbp-16]
    sub r8, rsp
    shr r8, 4 ; r8 now holds the number of elements to pop
%endmacro

%macro PUSH_LOCAL 1
    ; get local %1 from scope
    mov rdi, %1
    mov rsi, qword LOCAL_SCOPE
    call get_local
    ; push local to stack
    push rdx ; push data0
    push rax ; push data1
%endmacro

%macro DEBUG_RET 0
    mov rsp, rbp
    pop rbp
    ret
%endmacro

%macro RETURN 0
    GET_NELEMS
    ; load return stack
    mov rdi, LOCAL_RETURN
%%loop:
    ; check that there are still values to pop
    cmp r8, 0
    je %%ret
    dec r8
    ; store data arguments
    pop rdx
    pop rsi
    ; extend list with data
    push r8
    sub rsp, 8

    call memext

    add rsp, 8
    pop r8

    mov rdi, rax
    jmp %%loop
%%ret:
    ; discard scope pointer, padding and restore rbp
    add rsp, 16
    pop rbp
    ; return a reference to the current stack
    mov rax, rdi
    ret
%endmacro

%macro DEFINE 0
    ; extend local scope with LL in rax
    ; load scope, LL, type
    mov rdi, LOCAL_SCOPE
    mov rsi, rax
    mov rdx, 0x0000000100000000
    ; extend scope & write
    call memext
    mov LOCAL_SCOPE, rax
%endmacro

%macro BIND 1
    ; bind 128 bits to scope in %1
    mov rdi, %1
    pop rdx
    pop rsi
    call memext
    mov %1, rax
%endmacro

%macro CLOSURE 3
    call memalloc
    mov qword [rax], %3
    mov qword [rax+8], 1
    mov qword [rax+16], %1
    mov dword [rax+24], %2
    mov dword [rax+28], 0
    push rax
    mov rax, 0
    push rax
%endmacro

%macro INT 1
    mov r8, %1
    push r8
    mov r8, INT_TYPE
    push r8
%endmacro

%macro APPLY 0
    cmp dword [rsp+4], 0
    jne %%end
    add rsp, 8
    pop r9
    GET_NELEMS
%%apply:
    cmp qword [r9+24], 0
    je %%exec
    cmp r8, 0
    je %%pushc
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

    jmp %%apply
%%exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    MERGE
    jmp %%end
%%pushc:
    push r9
    mov r9, 0
    push r9
%%end:
%endmacro

%macro MERGE 0
    %%merge:
    cmp rax, 0
    je %%end
    cmp dword [rax+28], 0
    je %%closure
%%value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp %%merge
%%closure:
    GET_NELEMS
    mov r9, [rax+16]
    mov rdi, rax
    call memunext
%%apply:
    cmp qword [r9+24], 0
    je %%exec
    cmp r8, 0
    je %%pushc
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

    jmp %%apply
%%exec:
    mov rsi, [r9]
    mov rdi, rax
    call [r9+16]
    jmp %%merge
%%pushc:
    push r9
    mov r9, 0
    push r9
    jmp %%merge
%%end:
%endmacro