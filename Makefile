.PHONY: run

TARGET = riscv64-linux-musl
AS = $(TARGET)-as
LD = $(TARGET)-ld
OBJCOPY = $(TARGET)-objcopy

boot.img: boot.elf
	$(OBJCOPY) $< -I binary $@

boot.elf: boot/start.o
	$(LD) -Tboot.ld $< -o $@

boot/start.o: boot/start.s
	$(AS) $< -o $@

run:
	qemu-system-riscv64 -M virt -bios boot.img -serial stdio -display none
