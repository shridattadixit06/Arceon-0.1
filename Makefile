# Tools
ASM = nasm
CC = gcc
LD = ld
OBJCOPY = objcopy
QEMU = qemu-system-x86_64

# Output files
BOOT_BIN = boot.bin
ENTRY_OBJ = entry.o
KERNEL_OBJ = kernel.o
KERNEL_ELF = kernel.elf
KERNEL_BIN = kernel.bin
IMAGE = arceon.img

# Default target
all: $(IMAGE)

# -------------------------
# Bootloader
# -------------------------

$(BOOT_BIN): boot/boot.asm
	$(ASM) -f bin boot/boot.asm -o $(BOOT_BIN)

# -------------------------
# Kernel entry
# -------------------------

$(ENTRY_OBJ): kernel/entry.asm
	$(ASM) -f elf32 kernel/entry.asm -o $(ENTRY_OBJ)

# -------------------------
# C Kernel
# -------------------------

$(KERNEL_OBJ): kernel/kernel.c
	$(CC) -m32 \
		-ffreestanding \
		-fno-pie \
		-fno-stack-protector \
		-c kernel/kernel.c \
		-o $(KERNEL_OBJ)

# -------------------------
# Link kernel
# -------------------------

$(KERNEL_ELF): $(ENTRY_OBJ) $(KERNEL_OBJ) kernel/linker.ld
	$(LD) -m elf_i386 \
		-T kernel/linker.ld \
		-o $(KERNEL_ELF) \
		$(ENTRY_OBJ) $(KERNEL_OBJ)

# -------------------------
# Convert ELF → raw binary
# -------------------------

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $(KERNEL_ELF) $(KERNEL_BIN)
	truncate -s 512 $(KERNEL_BIN)

# -------------------------
# Create disk image
# -------------------------

$(IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	cat $(BOOT_BIN) $(KERNEL_BIN) > $(IMAGE)

# -------------------------
# Run in QEMU
# -------------------------

run: $(IMAGE)
	$(QEMU) -drive format=raw,file=$(IMAGE)

# -------------------------
# Clean
# -------------------------

clean:
	rm -f $(BOOT_BIN) \
	      $(ENTRY_OBJ) \
	      $(KERNEL_OBJ) \
	      $(KERNEL_ELF) \
	      $(KERNEL_BIN) \
	      $(IMAGE)

.PHONY: all run clean