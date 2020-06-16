#include <stdint.h>
#include <stdio.h>

struct memmeta {
    uint64_t blocks;
    void* loc;
};

typedef struct _block {
    uint64_t refs;
    struct _block* cons;
    uint64_t data0;
    uint64_t data1;
} Block;

typedef struct {
    uint64_t upper;
    uint64_t lower;
} uint128_t;

void memclear();
void memdrop(void* block);
Block* memalloc();
Block* memext(Block* parent, uint64_t data0, uint64_t data1);
uint128_t get_local(uint64_t n, Block* scope);

void indent(int len) {
    for (int i = 0; i < len; i++) {
        putc(' ', stdout);
    }
}

void debug_print_block(int in, Block* block) {
    indent(in);
    printf("BLOCK at %lx\n", block);
    indent(in);
    printf("refs: %ld\n", block->refs);
    indent(in);
    printf("data0: %lx\n", block->data0);
    indent(in);
    printf("data1: %lx\n", block->data1);
    if (block->cons != NULL) {
        debug_print_block(in+2, block->cons);
    }
}

void main() {
    memclear();
}