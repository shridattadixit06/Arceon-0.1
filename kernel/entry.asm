bits 32

global start
extern kernel_main

section .text

start:
    call kernel_main

hang:
    hlt
    jmp hang