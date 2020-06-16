nasm -felf64 test.asm
nasm -felf64 memory.asm
gcc test.c test.o memory.o
./a.out