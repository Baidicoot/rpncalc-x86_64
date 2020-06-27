; Calling Convention
; - rbp, rsp, r12-15 are saved across function calls
; - all other registers are not saved and must be saved by the caller
; - values are returned in rax, rbx, rcx, rdx
; - values are passed in rdi, rsi, rax, rbx, rcx, rdx
;
; Memory organisation
; - memory is divided into 4-qword 'blocks'
; - each block is structured like:
;   {
;       u32 arc;    // cleared upon push, stores the number of references to the current variable
;       u16 meta;   // data about the purpose of each of the datavars
;       u16 type;   // data about the object's type
;       u64 data0;  //
;       u64 data1;  // raw data
;       u64 data2;  //
;   }
;
; Multiple Return
; - multiply returned values are returned in a linked list of type 1, meta 110
;
; Builtin Types
; - 0, 100 - closure
; - 1, 110 - ll (scope/multiple return)

; amount of blocks to allocate upon memory overflow
%define ALLOC_SIZE 2048

extern heaploc  ; global variable with current heap start
extern heapsize ; global variable with current heap size (in bytes)
extern putint
extern putchar
extern putblock
extern putstr
extern putint

global getmeta
global getdata
global memalloc
global memclone
global memref
global memdrop
global memnew
global indexll
global consip
global unconsop
global consop
global givearg

section .text
drop_msg: db "drop: "
alloc_msg: db "alloc: "
alloc_err: db "failed to allocate", 0x0a

section .text
getmeta: ; get metadata about a block from a pointer
    ; rdi - block ptr
    mov eax, [rdi]
    mov bx, [rdi+4]
    mov cx, [rdi+6]
    ret

getdata: ; get data about a block from a pointer
    ; rdi - block ptr
    mov rax, [rdi+8]
    mov rbx, [rdi+16]
    mov rcx, [rdi+24]
    ret

memalloc: ; return a pointer to an unallocated block
    mov rax, [heaploc]
    mov rbx, [heaploc]
    add rbx, [heapsize]
.loop:
    cmp dword [rax], 0
    je .ret
    add rax, 32
    cmp rbx, rax
    jne .loop
.err:
    mov rax, 2
    mov rdx, alloc_err
    mov rsi, 19
    mov rdi, 1
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
.ret:
    ; push rax
    ; mov rdi, alloc_msg
    ; mov rsi, 7
    ; call putstr
    ; pop rax

    ; push rax
    ; mov rdi, rax
    ; call putint
    ; mov rdi, 0x0a
    ; call putchar
    ; pop rax

    ret

memdrop: ; deref a peice of memory
    ; rdi - block ptr
    ; push rdi
    ; mov rdi, drop_msg
    ; mov rsi, 6
    ; call putstr
    ; pop rdi

    ; push rdi
    ; call putblock
    ; pop rdi

    cmp rdi, 0
    je .ret

    dec dword [rdi]
    cmp dword [rdi], 0
    jne .ret
.drop:
    xor rbx, rbx
    mov bx, [rdi+4]
.d0:
    mov ax, 0b0000000000000100
    and ax, bx
    cmp ax, 0
    je .d1

    push rdi
    push rbx
    mov rdi, [rdi+8]
    call memdrop
    pop rbx
    pop rdi
.d1:
    mov ax, 0b0000000000000010
    and ax, bx
    cmp ax, 0
    je .d2
    push rdi
    push rbx
    mov rdi, [rdi+16]
    call memdrop
    pop rbx
    pop rdi
.d2:
    mov ax, 0b0000000000000001
    and ax, bx
    cmp ax, 0
    je .ret
    push rdi
    push rbx
    mov rdi, [rdi+24]
    call memdrop
    pop rbx
    pop rdi
.ret:
    ret

; ONLY USES RDI (!IMPORTANT!)
memref: ; duplicate a reference to a block
    ; rdi - block ptr
    cmp rdi, 0
    je .ret
    inc dword [rdi]
.ret:
    ret

memnew: ; construct a new peice of memory - DOES NOT PERFORM ANY REFERENCING
    ; di - metadata
    ; si - type
    ; rax - data0
    ; rbx - data1
    ; rcx - data2
    push rdi
    push rsi
    push rax
    push rbx
    push rcx
    call memalloc
    mov rdx, rax
    pop rcx
    pop rbx
    pop rax
    pop rsi
    pop rdi
    mov dword [rdx], 1
    mov [rdx+4], di
    mov [rdx+6], si
    mov [rdx+8], rax
    mov [rdx+16], rbx
    mov [rdx+24], rcx
    mov rax, rdx
    ret

memclone: ; clone an object and reference children
    ; rdi - ptr
    mov rax, [rdi+8]
    mov rbx, [rdi+16]
    mov rcx, [rdi+24]
    xor rsi, rsi
    mov si, [rdi+6]
    mov r8, rdi
    xor rdi, rdi
    mov di, [r8+4]
    call memnew
    ret
    push rax

    mov bx, [rdi+4]
.d0:
    mov ax, 0b0000000000000100
    and ax, bx
    cmp ax, 0
    je .d1

    push rdi
    mov rdi, [rdi+8]
    call memref
    pop rdi
.d1:
    mov ax, 0b0000000000000010
    and ax, bx
    cmp ax, 0
    je .d2

    push rdi
    mov rdi, [rdi+16]
    call memref
    pop rdi
.d2:
    mov ax, 0b0000000000000001
    and ax, bx
    cmp ax, 0
    je .ret

    push rdi
    mov rdi, [rdi+24]
    call memref
    pop rdi
.ret:
    pop rax
    ret

indexll: ; index a builtin linked list (not typechecked)
    ; rdi - ptr
    ; rsi - rel. index
    cmp rdi, 0
    je .err
    cmp rsi, 0
    je .ret
    mov rdi, [rdi+8]
    dec rsi
    jmp indexll
.err:
    mov rax, 0
    ret
.ret:
    mov rax, [rdi+16]
    ret

consop: ; cons a linked list (and perform referencing)
    ; rdi - ll
    ; rsi - data
    call memref
    push rdi
    mov rdi, rsi
    call memref
    pop rax
    mov rbx, rsi

    xor rcx, rcx
    xor rdi, rdi
    xor rsi, rsi

    mov si, 1
    mov di, 0b0000000000000110
    call memnew
    ret

consip: ; cons a linked list (don't perform any referencing)
    ; rdi - ll
    ; rsi - data
    mov rax, rdi
    mov rbx, rsi
    xor rcx, rcx
    xor rdi, rdi
    xor rsi, rsi

    mov si, 1
    mov di, 0b0000000000000110
    call memnew
    ret

unconsop: ; uncons a ll (deref pairing object) - essentiall extract x, xs part of list
    ; rdi - ll
    cmp rdi, 0
    je .err

    push rdi
    mov rdi, [rdi+8]
    call memref
    pop rdi

    push rdi
    mov rdi, [rdi+16]
    call memref
    pop rdi

    push qword [rdi+8]
    push qword [rdi+16]
    call memdrop
    pop rbx
    pop rax

    ret
.err:
    mov rax, 0
    ret

givearg: ; extend a closure (not typechecked)
    ; rdi - ptr to data
    ; rsi - ptr to closure
    push rdi
    push rsi
    mov rdi, rsi
    call memclone       ; clone = memclone(closure)
    pop rsi
    pop rdi
    ; rax - closure clone
    ; rdi - data
    ; rsi - old closure
    dec qword [rax+24]
    push rsi
    push rax
    mov rsi, rdi
    mov rdi, [rax+8]    ; scope = clone[8]
    call consop         ; scope' = consop(scope, data)
    mov rdi, rax
    pop rax
    mov [rax+8], rdi    ; clone[8] = scope'
    pop rdi
    push rax
    call memdrop        ; drop(closure)
    pop rax
    ret                 ; return(clone)