
%include "raw/macro.asm"
extern io_printscope
extern io_putchar
extern io_putbyte
extern io_putint
extern io_sayhi
extern scopemem
extern scopelen
global io_helloworld

io_helloworld:
    FUNCTION
    INT 10
    INT 33
    INT 100
    INT 108
    INT 114
    INT 111
    INT 87
    INT 32
    INT 44
    INT 111
    INT 108
    INT 108
    INT 101
    INT 72
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    mov r11, io_putchar
    mov rsi, LOCAL_SCOPE
    CLOSURE r11, 1, rsi
    RESOLVE
    RETURN