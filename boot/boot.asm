bits 16
org 0x7c00

start:

    mov ah, 0x0e

    mov si, loading_message

print_loop:

    mov al, [si]

    cmp al, 0
    je load_kernel

    int 0x10

    inc si
    jmp print_loop


load_kernel:

    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 0x80

    mov bx, 0x8000

    int 0x13

    jc disk_error

    jmp 0x8000


disk_error:

    mov si, error_message

error_loop:

    mov ah, 0x0e
    mov al, [si]

    cmp al, 0
    je hang

    int 0x10

    inc si
    jmp error_loop


loading_message db 'Loading Arceon kernel...', 0
error_message db 'Disk read failed!', 0


hang:

    hlt
    jmp hang


times 510-($-$$) db 0
dw 0xaa55