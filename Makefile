.PHONY: all run-qemu clean

include make.conf

all: kernel init0 initrd.img bin
	make -C kernel install
	make -C init0 install
	make -C bin install

clean: kernel
	make -C kernel clean
	make -C init0 clean
	make -C bin clean
	rm -rf sysroot/
	rm -rf initrd/
	rm -rf initrd.img

initrd.img: bin/sh/sh
	sudo rm -rf initrd/
	mkdir -p initrd/dev/
	sudo mknod initrd/dev/console c 0 0
	mkdir initrd/bin
	cp bin/sh/sh initrd/bin/
	$(TAR) --owner=0 --group=0 --numeric-owner --exclude-vcs --show-transformed-names -cvf ./initrd.img --transform 's,initrd,,' initrd/

QEMU_CMD:=qemu-system-i386 -kernel sysroot/boot/kernel.bin -serial mon:stdio -m 2G -initrd "initrd.img,sysroot/boot/init0.elf"

run-qemu: all
	$(QEMU_CMD)

run-qemu-gdb: all
	$(QEMU_CMD) -S -s
