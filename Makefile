.PHONY: run clean

TARGET = riscv64-linux-musl
AS = $(TARGET)-as
LD = $(TARGET)-ld
OBJCOPY = $(TARGET)-objcopy

boot.img: boot.elf
	$(OBJCOPY) $< -I binary $@

boot.elf: boot/start.o boot.ld
	$(LD) -Tboot.ld $< -o $@

boot/start.o: boot/start.s
	$(AS) $< -o $@

prog.img: prog.nc
	cp prog.nc prog.img
	dd if=/dev/null of=prog.img bs=1 count=1 seek=32M

run: prog.img boot.img
	qemu-system-riscv64 -M virt -bios boot.img -serial stdio -display none -drive if=pflash,file=prog.img,format=raw,index=1

clean:
	rm *.img boot/*.o *.elf
