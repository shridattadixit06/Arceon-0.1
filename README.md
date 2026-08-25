# Arceon 0.1

**Arceon** is a minimal educational operating-system project built from scratch to understand the fundamental process of booting a computer, loading a kernel, executing low-level code, and transitioning from assembly into a C-based kernel environment.

This version focuses on the **base-level concepts of operating systems, x86 architecture, bootloaders, assembly, memory, and the compilation/linking toolchain**.

> **Arceon 0.1 is an educational foundation, not a complete operating system.**

---

## Project Goal

The primary goal of Arceon 0.1 is to understand what happens between:

```text
Computer Power On
        ↓
       BIOS
        ↓
   Bootloader
        ↓
    Kernel Load
        ↓
      Kernel
```

Instead of using an existing bootloader or operating-system framework, the project implements the basic boot process manually.

---

# Current Architecture

```text
                    Computer Starts
                           │
                           ▼
                         BIOS
                           │
                           ▼
                  Loads Boot Sector
                           │
                           ▼
                     0x7C00 in RAM
                           │
                           ▼
                  Arceon Bootloader
                           │
                ┌──────────┴──────────┐
                │                     │
                ▼                     ▼
           BIOS Video            BIOS Disk I/O
            INT 10h                INT 13h
                │                     │
                ▼                     ▼
             Screen             Load Kernel
                                      │
                                      ▼
                               Kernel @ 0x8000
                                      │
                                      ▼
                                Transfer Control
                                      │
                                      ▼
                                  C Kernel
```

---

# Project Structure

```text
Arceon/
│
├── boot/
│   └── boot.asm
│
├── kernel/
│   ├── kernel.c
│   ├── entry.asm
│   └── linker.ld
│
├── Makefile
├── README.md
└── arceon.img
```

## Files

### `boot/boot.asm`

The bootloader.

Responsibilities include:

* Running in 16-bit Real Mode
* Displaying boot messages using BIOS
* Reading the kernel from disk using BIOS disk services
* Loading the kernel into memory at `0x8000`
* Transferring execution to the loaded kernel

---

### `kernel/kernel.c`

The initial freestanding C kernel.

It demonstrates:

* Running C without a normal operating-system environment
* Direct memory access
* VGA text-mode memory
* Basic kernel entry logic

The kernel does not use standard functions such as `printf()` because Arceon does not have a C runtime or operating system underneath it.

---

### `kernel/entry.asm`

The assembly entry point for the C kernel.

It provides the bridge between low-level assembly and C:

```text
Assembly
   ↓
kernel_main()
   ↓
C Kernel
```

The file contains the `start` entry symbol and calls `kernel_main`.

---

### `kernel/linker.ld`

The custom linker script.

It tells the linker:

* Where the kernel should be located in memory
* Which symbol is the entry point
* How `.text`, `.rodata`, `.data`, and `.bss` sections are arranged

The kernel is linked around:

```text
0x8000
```

because the bootloader loads the kernel at that address.

---

### `Makefile`

Contains the commands required to compile, assemble, link, and construct the disk image.

---

# Important Concepts Learned

## 1. x86 Registers

The project introduced basic x86 registers such as:

```text
AX
├── AH
└── AL

SI
```

`AL` was used for character data while `SI` was used to hold memory addresses while iterating through strings.

---

## 2. Memory Addressing

The project introduced the idea that memory can be accessed using addresses.

For example:

```asm
mov al, [si]
```

means:

> Read the byte stored at the memory address contained in `SI` and place it in `AL`.

---

## 3. Strings in Assembly

A string such as:

```asm
message db 'Arceon', 0
```

is stored as individual bytes:

```text
'A'
'r'
'c'
'e'
'o'
'n'
 0
```

The final `0` is used as a null terminator.

---

## 4. BIOS Video Services

The bootloader uses:

```asm
int 0x10
```

to request video-related services from the BIOS.

For character output:

```asm
mov ah, 0x0e
mov al, 'A'
int 0x10
```

---

## 5. BIOS Disk Services

The bootloader uses:

```asm
int 0x13
```

to request disk operations from the BIOS.

This allows the bootloader to read the kernel from the disk image.

---

## 6. Boot Sector

The BIOS boot sector is:

```text
512 bytes
```

and ends with:

```text
55 AA
```

The bootloader uses:

```asm
times 510-($-$$) db 0
dw 0xaa55
```

to fill the sector and place the boot signature.

---

## 7. Kernel Loading

The bootloader loads the kernel into:

```text
0x8000
```

The basic disk layout is:

```text
Disk Image
│
├── Sector 1 → Bootloader
│
└── Sector 2 → Kernel
```

The current version intentionally uses a **single kernel sector**.

Multi-sector kernel loading is outside the scope of Arceon 0.1.

---

# C Kernel and Compilation

The project uses a freestanding C environment.

The C kernel is compiled using:

```bash
gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -c kernel/kernel.c -o kernel.o
```

### Important options

| Option                 | Purpose                                            |
| ---------------------- | -------------------------------------------------- |
| `-m32`                 | Generate 32-bit x86 code                           |
| `-ffreestanding`       | Compile for a freestanding environment             |
| `-fno-pie`             | Disable position-independent executable generation |
| `-fno-stack-protector` | Disable stack-protection instrumentation           |
| `-c`                   | Compile without linking                            |

The result is:

```text
kernel.o
```

---

# Assembly Entry Point

The assembly entry point is assembled using:

```bash
nasm -f elf32 kernel/entry.asm -o entry.o
```

This produces:

```text
entry.o
```

The two object files are:

```text
entry.o
kernel.o
```

---

# Linking

The object files are combined using the linker:

```bash
ld -m elf_i386 -T kernel/linker.ld -o kernel.elf entry.o kernel.o
```

This produces:

```text
kernel.elf
```

The linker:

* Combines object files
* Resolves symbols
* Assigns addresses
* Arranges sections
* Determines the entry point
* Produces the final ELF image

---

# Linker Script

The important part of the linker script is:

```ld
ENTRY(start)

SECTIONS
{
    . = 0x8000;

    .text :
    {
        *(.text)
    }

    .rodata :
    {
        *(.rodata)
    }

    .data :
    {
        *(.data)
    }

    .bss :
    {
        *(.bss)
    }
}
```

The line:

```ld
. = 0x8000;
```

makes the linker arrange the kernel around the address where the bootloader loads it.

The bootloader and linker therefore agree:

```text
Bootloader:
Kernel → 0x8000

Linker:
Kernel → 0x8000
```

---

# ELF to Raw Binary

The bootloader does not understand the ELF format.

Therefore:

```bash
objcopy -O binary kernel.elf kernel.bin
```

converts:

```text
kernel.elf
     ↓
kernel.bin
```

`kernel.bin` contains the raw binary data that the bootloader can load directly.

---

# Kernel Size

The initial C kernel binary was:

```text
184 bytes
```

Since the bootloader currently reads one complete sector:

```text
1 sector = 512 bytes
```

the kernel binary was padded to:

```text
512 bytes
```

using:

```bash
truncate -s 512 kernel.bin
```

---

# Building the Disk Image

The bootloader and kernel are combined:

```bash
cat boot.bin kernel.bin > arceon.img
```

The resulting image contains:

```text
┌──────────────────────────┐
│ Sector 1                 │
│ Bootloader               │
│ 512 bytes                │
├──────────────────────────┤
│ Sector 2                 │
│ Kernel                   │
│ 512 bytes                │
└──────────────────────────┘
```

Total:

```text
1024 bytes
```

---

# Running Arceon

## Requirements

You need:

* GCC
* NASM
* GNU Make
* GNU Binutils (`ld`, `objcopy`)
* QEMU

On Ubuntu, the required packages can be installed with:

```bash
sudo apt update
sudo apt install gcc nasm make binutils qemu-system-x86
```

Check the installations:

```bash
gcc --version
nasm -v
make --version
ld --version
objcopy --version
qemu-system-x86_64 --version
```

---

# Build Manually

If you want to understand every stage, run the commands individually.

### 1. Assemble the bootloader

```bash
nasm -f bin boot/boot.asm -o boot.bin
```

### 2. Assemble the kernel entry point

```bash
nasm -f elf32 kernel/entry.asm -o entry.o
```

### 3. Compile the C kernel

```bash
gcc -m32 -ffreestanding -fno-pie -fno-stack-protector -c kernel/kernel.c -o kernel.o
```

### 4. Link the kernel

```bash
ld -m elf_i386 -T kernel/linker.ld -o kernel.elf entry.o kernel.o
```

### 5. Convert ELF to raw binary

```bash
objcopy -O binary kernel.elf kernel.bin
```

### 6. Pad the kernel to one sector

```bash
truncate -s 512 kernel.bin
```

### 7. Create the disk image

```bash
cat boot.bin kernel.bin > arceon.img
```

### 8. Run in QEMU

```bash
qemu-system-x86_64 -drive format=raw,file=arceon.img
```

---

# Building Using Make

If the Makefile is configured, the complete process can be reduced to:

```bash
make
```

Then run:

```bash
make run
```

If the Makefile does not contain a `run` target, use:

```bash
qemu-system-x86_64 -drive format=raw,file=arceon.img
```

To remove generated build files:

```bash
make clean
```

---

# Current Limitations

Arceon 0.1 intentionally stops before entering 32-bit Protected Mode.

It does **not** yet implement:

* Protected Mode
* GDT
* 32-bit CPU initialization
* Proper kernel stack initialization
* Interrupt Descriptor Table
* Hardware interrupts
* Keyboard driver
* Memory management
* Paging
* Virtual memory
* Processes
* Threads
* Scheduling
* System calls
* Filesystem
* Device drivers
* Networking
* User programs
* Multitasking

These are intentionally left for future OS development.

---

# Why the Project Stops Here

The current bootloader operates in:

```text
16-bit Real Mode
```

while the C kernel was compiled as:

```text
32-bit x86 code
```

The next major step would therefore require a transition:

```text
16-bit Real Mode
        ↓
       GDT
        ↓
Protected Mode
        ↓
32-bit environment
        ↓
Stack initialization
        ↓
C kernel
```

Understanding Computer Organization and Architecture before implementing this stage makes the next phase much easier to understand.

Therefore, **Arceon 0.1 intentionally ends at this foundation stage.**

---

# Learning Outcome

By completing Arceon 0.1, the following complete chain was explored:

```text
Hardware
   ↓
BIOS
   ↓
Boot Sector
   ↓
Bootloader
   ↓
BIOS Interrupts
   ↓
Disk Sectors
   ↓
Memory Addresses
   ↓
Kernel Loading
   ↓
Assembly
   ↓
C
   ↓
Object Files
   ↓
Linker
   ↓
Linker Script
   ↓
ELF
   ↓
Raw Binary
   ↓
Disk Image
   ↓
QEMU
```

The project demonstrates the basic relationship between **hardware, firmware, bootloaders, machine code, assembly, C, memory, and the compiler toolchain**.

---

# Version

**Arceon 0.1**

Status:

```text
Foundation Complete
```

The project is intentionally preserved as a learning reference for future OS development.

---

## Future Direction

A future OS project will rebuild these concepts from scratch and continue beyond this foundation into:

```text
Real Mode
   ↓
Protected Mode
   ↓
GDT
   ↓
Interrupts
   ↓
Memory Management
   ↓
Paging
   ↓
Processes
   ↓
Scheduling
   ↓
System Calls
   ↓
Filesystem
   ↓
Drivers
   ↓
Networking
```

The next project will be developed with a stronger understanding of Computer Organization, Architecture, and Operating Systems.
