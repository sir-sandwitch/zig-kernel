SOURCES=src/main.zig

LDFLAGS=-Tlink.ld

all: $(SOURCES)
	zig build

iso: all
	cp kernel.elf isodir/boot/kernel.elf
	grub-mkrescue -o os.iso isodir

run: iso
	qemu-system-i386 -cdrom os.iso