void kernel_main()
{
    volatile char *video = (volatile char *)0xB8000;

    video[0] = 'A';
    video[1] = 0x07;

    video[2] = 'r';
    video[3] = 0x07;

    video[4] = 'c';
    video[5] = 0x07;

    video[6] = 'e';
    video[7] = 0x07;

    video[8] = 'o';
    video[9] = 0x07;

    video[10] = 'n';
    video[11] = 0x07;

    while(1)
    {
        __asm__ volatile ("hlt");
    }
}