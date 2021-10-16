VER = 0.1.0-indev

.PHONY: all
all: mkdir bootloader kernel link spwn iso
	@echo Build complete.

mkdir:
	mkdir -pv out/ build/ iso/ iso/boot/ iso/boot/grub/ iso/lib/ iso/bin/

bootloader: src/core/boot.asm
	nasm -f elf32 src/core/boot.asm -o build/boot.o

kernel: src/core/kernel.rs
	rustc src/core/kernel.rs --target=i686-unknown-linux-gnu --emit=obj -o build/kernel.o

link: src/core/link.ld build/boot.o build/kernel.o
	ld -m elf_i386 -T src/core/link.ld -o build/kernel build/boot.o build/kernel.o

iso: build/kernel
	cp build/kernel iso/boot/
	cp src/core/grub.cfg iso/boot/grub/
	grub-file --is-x86-multiboot iso/boot/kernel
	grub-mkrescue -o out/arc-$(VER).iso iso/

.PHONY: clean
clean:
	rm -rf build/ iso/ out/