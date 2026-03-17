BUILDROOT_DIR := modules/buildroot
BR2_EXTERNAL  := $(CURDIR)/modules/buildroot-external-st
DEFCONFIG     := stm32mp257DAK_core_defconfig
NPROC         := $(shell nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2)
CCACHE_DIR    ?= $(HOME)/.buildroot-ccache

.PHONY: defconfig build clean menuconfig savedefconfig

defconfig:
	$(MAKE) -C $(BUILDROOT_DIR) BR2_EXTERNAL=$(BR2_EXTERNAL) $(DEFCONFIG)

build: defconfig
	$(MAKE) -C $(BUILDROOT_DIR) BR2_CCACHE=y BR2_CCACHE_DIR=$(CCACHE_DIR) -j$(NPROC)

clean:
	$(MAKE) -C $(BUILDROOT_DIR) clean

menuconfig:
	$(MAKE) -C $(BUILDROOT_DIR) BR2_EXTERNAL=$(BR2_EXTERNAL) menuconfig

savedefconfig:
	$(MAKE) -C $(BUILDROOT_DIR) BR2_EXTERNAL=$(BR2_EXTERNAL) savedefconfig
