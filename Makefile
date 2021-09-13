# If local QEmu build does not exist, use system wide installed QEmu
QEMU ?= ./qemu-build/bin/qemu-system-riscv64
ifeq ($(wildcard $(QEMU)),)
	QEMU = qemu-system-riscv64
endif

OUT := out

# This target makes all the binaries depend on existence (but not timestamp) of
# $(OUT), which lets us avoid repetitive 'mkdir -p out'
$(BINS): | $(OUT)

$(OUT)/generic-elf/hello:
	@mkdir -p $(OUT)/generic-elf
	$(RISCV64_GCC) -static -o $@ src/generic-elf/hello.c src/generic-elf/hiasm.S

.PHONY: run-linux
run-linux: initrd
	$(QEMU) -nographic -machine virt \
     -kernel linux/arch/riscv/boot/Image -append "root=/dev/vda ro console=ttyS0" \
     -drive file=busybox/busybox,format=raw,id=hd0 \
     -device virtio-blk-device,drive=hd0 \
     -initrd initramfs-busybox-riscv64.cpio.gz

clean:
	rm -Rf initramfs

prereqs:
	sudo apt --yes install \
		autoconf \
		automake \
		autotools-dev \
		bc \
		bison \
		build-essential \
		curl \
		device-tree-compiler \
		flex \
		gawk \
		gcc-riscv64-linux-gnu \
		git \
		libexpat-dev \
		libglib2.0-dev \
		libpixman-1-dev \
		libgmp-dev \
		libmpc-dev \
		libmpfr-dev \
		libtool \
		patchutils \
		pkg-config \
		texinfo gperf \
		zlib1g-dev

clone:
	git clone https://github.com/qemu/qemu
	git clone https://github.com/torvalds/linux
	git clone https://git.busybox.net/busybox

.PHONY: qemu
qemu:
	./scripts/build-qemu.sh

.PHONY: busybox
busybox:
	./scripts/build-busybox.sh

.PHONY: linux
linux:
	./scripts/build-linux.sh

.PHONY: initrd
initrd:
	./scripts/build-initrd.sh
