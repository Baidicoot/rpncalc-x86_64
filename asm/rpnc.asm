%define BLOCKS 128

; OBJECT repr
; 12 bytes of 'data'
;  4 bytes of 'type'

; OBJECT types
;  0 - closure;     8 bytes of ptr, 4 bytes of nargs
;  1 - list/tuple;  8 bytes of ptr, 4 bytes of nothing

; MERGE/RETURN semantics
; all functions return a list
; upon merge, every item in the list is sequentially applied to the stack
; during application;
; if it is a function it is called
; otherwise it is pushed

; CALLING CONVENTION:
; - no registers are guaranteed to be saved
; - return stack is passed in rdi, scope is passed in rsi

%ifndef RPNC_MACROS
%define RPNC_MACROS

%define LOCAL_SCOPE [rbp-16]
%define LOCAL_RETURN [rbp-8]

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
    push rax ; push data0
    push rdx ; push data1
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
    call memext
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
    ; push a closure around %1 with %2 arguments and %3 scope
    call memalloc
    mov qword [rax], 1
    mov qword [rax+8], 0
    mov qword [rax+16], %3
    mov qword [rax+24], %1
    push rax
    sub rsp, 8
    mov dword [rsp+8], %2
    mov dword [rsp+4], 0
%endmacro

%macro MERGE 0
%%merge:
    ; check if there are still values to push
    cmp rax, 0
    je %%end
    ; test type of returned element
;     cmp dword [rax+28], 0
;     je %%closure
%%value:
    push qword [rax+16]
    push qword [rax+24]
    mov rdi, rax
    call memunext
    jmp %%merge
; TODO - clean up closure code *massively*
; %%closure:
    ; r8 - stores nelems; r9 - stores nargs; r10 - stores closure scope
    ; r11 - stores closure ptr; rcx - stores rest of return list
;     GET_NELEMS
;     mov r9d, dword [rax+24]
;     mov r11, [rax+16] ; load closure ptr
;     mov r10, [r11+16] ; load pointed scope
;     call memunext
;     mov rcx, rax
; %%bind_loop:
;     cmp r9, 0
;     je %%exec
;     cmp r8, 0
;     je %%push
;     BIND r10
;     mov r10, rax
;     jmp %%bind_loop
; %%exec:
;     mov rdi, rcx
;     mov rsi, r10
;     call [r11+8]

;     mov rdi, r11
;     call memdrop

;     mov rax, rcx
;     jmp %%merge
; %%push:
;     lea r8, [r11+24]
;     CLOSURE r8, r9d, r10

;     mov rdi, r11
;     call memdrop

;     mov rax, rcx
;     jmp %%merge
%%end:
%endmacro

%endif

global memdata
global memalloc
global memdrop
global memcons
global memext
global get_local
global testfn

section .bss
; memory is a large array of 4-qword (32 byte) 'blocks'
; it is kept track of using ARC
; if a block has 0 refs, it is counted as free
scopemem: resq BLOCKS*4

section .text
idfn:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov qword [rbp-8], rdi
    mov qword [rbp-16], rsi

    PUSH_LOCAL 0

    RETURN

testfn:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    mov qword [rbp-8], 0
    mov qword [rbp-16], 0

    mov rdi, qword [rbp-8]
    mov rsi, qword [rbp-16]

    mov rax, 12
    
    push rax
    push rax

    mov rax, 15

    push rax
    push rax

    push rax
    push rax

    BIND rsi
    BIND rsi
    BIND rsi

    mov rdi, 0

    call idfn
    MERGE

    RETURN

memdata: ; metadata about the memory segment
    mov rdx, scopemem
    mov rax, BLOCKS
    ret

memalloc: ; allocate a free block
    mov rax, scopemem
    ; check if block is free (has 0 references)
    cmp qword [rax], 0
    je .ret
.loop:
    ; move to next block
    add rax, 32
    cmp qword [rax], 0
    jne .loop
.ret:
    ret

memdrop:
    sub rsp, 8
    ; rdi - address of memory to deref
    dec qword [rdi]
    ; check if there are no refs
    cmp qword [rdi], 0
    jne .ret
.rec:
    ; check if the block is nil
    cmp qword [rdi+8], 0
    je .ret
    ; if not, deref that as well
    mov rdi, qword [rdi+8]
    call memdrop
.ret:
    add rsp, 8
    ret

memext:
    sub rsp, 8
    ; rdi - address of parent block to deref
    ; rsi - data0
    ; rdx - data1
    ; returns new block in rax

    ; allocate space for new block
    call memalloc
    ; write new block
    mov qword [rax], 1
    mov qword [rax+8], rdi
    mov qword [rax+16], rsi
    mov qword [rax+24], rdx
    ; return new block address
    add rsp, 8
    ret

memunext: ; takes non-null ptr in rdi, ref-returns child and derefs
    sub rsp, 8
    mov rax, [rdi+8]
    cmp rax, 0
    je .end
.nz:
    inc qword [rax]
.end:
    call memdrop
    add rsp, 8
    ret

memcons: ; like memext, but keeps ref
    sub rsp, 8
    ; rdi - address of parent block (non-NULL)
    ; rsi - data0
    ; rdx - data1
    ; returns new block in rax

    ; reference parent block
    inc qword [rdi]
    ; allocate space for new block
    call memalloc
    ; write new block
    mov qword [rax], 1
    mov qword [rax+8], rdi
    mov qword [rax+16], rsi
    mov qword [rax+24], rdx
    ; return block address
    add rsp, 8
    ret

get_local:
    ; rdi - nth local
    ; rsi - scope ptr
.loop:
    ; check if this is the correct scope to get
    cmp rdi, 0
    je .ret
    ; move to next scope/index
    mov rsi, qword [rsi+8]
    dec rdi
    jmp .loop
.ret:
    mov rax, [rsi+16] ; rax = data0
    mov rdx, [rsi+24] ; rdx = data1
    ret