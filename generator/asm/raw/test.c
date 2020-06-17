#include <stdint.h>
#include <stdio.h>

typedef struct _block {
    struct _block* cons;
    uint64_t refs;
    uint64_t data0;
    uint64_t data1;
} Block;

typedef struct {
    Block* scope;
    uint64_t refs;
    void* fn;
    uint64_t args;
} Closure;

typedef struct {
    uint64_t upper;
    uint64_t lower;
} uint128_t;

void debug_print_block(Block* block) {
    printf("BLOCK at %lx\n", block);
    printf("refs: %ld\n", block->refs);
    printf("data0: %lx\n", block->data0);
    printf("data1: %lx\n", block->data1);
    if (block->cons != NULL) {
        printf("{\n");
        debug_print_block(block->cons);
        printf("}\n");
    }
}

void memdrop(void* block);
Block* memalloc();
Block* memext(Block* parent, uint64_t data0, uint64_t data1);
Block* memunext(Block* b);
uint128_t get_local(uint64_t n, Block* scope);
void memclear();
Closure* give_arg(Closure* fn, uint64_t data0, uint64_t data1);
Closure* give_arg0(Closure* fn, uint64_t data0, uint64_t data1);

Block* _0(Block* ret, Block* scope);

void main() {
    memclear();
    Block* b = _0(NULL, NULL);
    debug_print_block(b);
    printf("\n");
    debug_print_block(b->data0);
}