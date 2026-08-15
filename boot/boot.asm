bits 16
org 0x7c00

start:
    mov ah, 0x0e
    mov si, message

my_loop:                
    mov al, [si]
    cmp al, 0
    je hang
    
    int 0x10
    inc si
    jmp my_loop         

message db 'Arceon', 0

hang:
    hlt
    jmp hang

times 510-($-$$) db 0
dw 0xaa55   