#include <stdio.h>
#include "master.h"

void executor_start_hook() {
    printf("Hello, world!\n");
}

void init() {
    executor_start_hook = &executor_start_hook;
    printf("greeting initialized\n");
}

void fini() {
    executor_start_hook = NULL;
    printf("greeting finished\n");
}

const char* name() {
    return "greeting";
}