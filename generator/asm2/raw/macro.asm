%ifndef MACROS
%define MACROS
%define LOCAL_SCOPE qword [rbp-16]
%define LOCAL_RETURN qword [rbp-8]

extern getmeta
extern getdata
extern memalloc
extern memclone
extern memref
extern memdrop
extern memnew
extern indexll
extern consip
extern unconsop
extern consop
extern givearg

extern putw
extern putchar
extern putblock

%macro FUNCTION 0
    ; initialisation macro for functions
    ; saves rbp for parent function & updates to point to base of this stack
    ; pushes pointer to local scope (ll of objects) and 'return stack' (ll of objects)
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
    ; div by 8 (each element is a ptr)
    shr r8, 3
%endmacro

%macro PUSH_LOCAL 1
    ; references & pushes an indexed local to the stack
    mov rsi, %1
    mov rdi, LOCAL_SCOPE
    call indexll
    mov rdi, rax
    call memref
    push rdi
%endmacro

%macro GET_LOCAL 1
    ; like push_local, but does not ref or push
    mov rsi, %1
    mov rdi, LOCAL_SCOPE
    call indexll
%endmacro

%macro DEBUG_RET 0
    mov rsp, rbp
    pop rbp
    ret
%endmacro

%macro RETURN 0
    ; extends the return stack with all the values on the current stack frame
    ; unwinds to rbp, derefs local scope, returns ptr to return stack in rax
    GET_NELEMS
    mov rdi, LOCAL_RETURN
%%loop:
    cmp r8, 0
    je %%ret
    dec r8
    pop rsi
    push r8
    call consip
    pop r8
    mov rdi, rax
    jmp %%loop
%%ret:
    push rdi
    mov rdi, LOCAL_SCOPE
    call memdrop
    pop rdi
    add rsp, 16
    pop rbp
    mov rax, rdi
    ret
%endmacro

%macro DEFINE 0
    ; cons rax & local scope
    mov rdi, LOCAL_SCOPE
    mov rsi, rax
    call consip
    mov LOCAL_SCOPE, rax
%endmacro

%macro BIND 1
    ; probably not used? cons value & arbitrary scope in %1
    mov rdi, %1
    pop rsi
    call consip
    mov %1, rax
%endmacro

%macro DROP 1
    ; retrive a scope without the top %1 values
    mov rsi, LOCAL_SCOPE
%rep %1
    mov rsi, [rsi+8]
%endrep
%endmacro

%macro INITCALL 0
    ; also maybe not used?
    ; stores & references local scope and return stack for passing to function
    mov rdi, LOCAL_SCOPE
    call memref
    mov rsi, rdi
    mov rdi, LOCAL_RETURN
    call memref
%endmacro

%macro INITCALL 2
    ; pbbly not used, similar to INITCALL
    mov rdi, %1
    call memref
    mov rdi, rsi
    mov rdi, %2
    call memref
%endmacro

%macro CLOSURE 3
    ; create closure around fn %1, with %2 values and scope %3
    ; references %3/scope
    push %1
    push %2
    mov rdi, %3
    call memref
    mov rax, rdi
    pop rcx
    pop rbx
    mov di, 0b100
    mov si, 0
    call memnew
    push rax
%endmacro

%macro INT 1
    mov di, 0
    mov si, 2
    mov rax, %1
    xor rbx, rbx
    xor rcx, rcx
    call memnew
    push rax
%endmacro

; not typechecked
%macro APPLY 1
    ; applies a closure in %1 to the stack using a return stack in rax
    ; rax - return stack
    ; %1 - closure
    mov rsi, %1
    GET_NELEMS
%%apply:
    ; checks if the closure is fully evalulated, if so execute, else pop value off and give to closure
    cmp qword [rsi+24], 0
    je %%exec
    cmp r8, 0
    je %%pushc
    dec r8
    pop rdi
    push rax
    push r8
    call givearg
    mov rsi, rax
    pop r8
    pop rax
    jmp %%apply
%%exec:
    push rsi
    mov r8, [rsi+16]
    mov rdi, rax
    mov rsi, [rsi+8]
    call r8
    pop rsi

    jmp %%end
%%pushc:
    push rsi
%%end:
%endmacro

%macro MERGE 0
    ; merge return stack with actual stack
    ; iterates through return stack ll, applying values it finds
    ; if it finds a closure, it applies it to the stack, calling it if it needs to
    ; passing in the remainder of the return stack to the closure
%%merge:
    cmp rax, 0
    je %%end
    mov rdi, rax
    call unconsop
    push rax
    push rbx
    mov rdi, rbx
    call getmeta
    pop rbx
    pop rax
    cmp cx, 0
    je %%closure
%%pushv:
    push rbx
    jmp %%merge
%%closure:
    ; applying the closure basically updates rax with [new returns] + [remainder of return stack]
    APPLY rbx
    jmp %%merge
%%end:
%endmacro

%macro RESOLVE 0
    ; pops value off stack, tries to either merge it or apply it
    mov rdi, [rsp]
    call getmeta
    cmp cx, 0
    je %%closure
    cmp cx, 1
    je %%list
    jmp %%end
%%closure:
    pop rbx
    xor rax, rax
    APPLY rbx
    MERGE
    jmp %%end
%%list:
    pop rax
    MERGE
%%end:
%endmacro

%endif