bits 16
org 0x7c00

start:
    mov ah, 0x0e
    mov al, 'A'
    int 0x10   
    mov al, 'R'
    int 0x10
    mov al, 'C'
    int 0x10
    mov al, 'E'
    int 0x10
    mov al, 'O'
    int 0x10
    mov al, 'N'
    int 0x10

hang:
    hlt
    jmp hang

times 510-($-$$) db 0
dw 0xaa55