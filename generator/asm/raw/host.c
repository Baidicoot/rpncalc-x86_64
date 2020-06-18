#include <stdint.h>
#include <stdio.h>

typedef struct _block {
    struct _block* cons;
    uint64_t refs;
    uint64_t data0;
    uint32_t data1;
    uint32_t type;
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

void print_output(Block* block) {
    switch (block->type)
    {
    case 0:
        printf("(closure; needs %i) ", ((Closure*)block->data0)->args);
        break;
    
    case 1:
        printf("list ");
        break;
    
    case 2:
        printf("%i ", block->data0);
        break;
    
    default:
        break;
    }
    if (block->cons != NULL) {
        print_output(block->cons);
    }
}

Block* _0(Block* ret, Block* scope);

void main() {
    memclear();
    Block* b = _0(NULL, NULL);
    print_output(b);
    printf("\n");
}