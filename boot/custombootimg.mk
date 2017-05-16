LOCAL_PATH := $(call my-dir)

DEVICE_LOGORLE := device/sony/yuga/boot/logo.rle

recovery_uncompressed_twrp_ramdisk := $(PRODUCT_OUT)/ramdisk-twrp.cpio
$(recovery_uncompressed_twrp_ramdisk): $(MKBOOTFS) \
		$(INTERNAL_RECOVERYIMAGE_FILES) \
		$(recovery_initrc) $(recovery_sepolicy) $(recovery_kernel) \
		$(INSTALLED_2NDBOOTLOADER_TARGET) \
		$(recovery_build_prop) $(recovery_resource_deps) $(recovery_root_deps) \
		$(recovery_fstab) \
		$(RECOVERY_INSTALL_OTA_KEYS) \
		$(INTERNAL_BOOTIMAGE_FILES)
	$(call build-recoveryramdisk)
	@echo "----- Making uncompressed recovery ramdisk ------"
	$(hide) cp $(DEVICE_LOGORLE) $(TARGET_RECOVERY_ROOT_OUT)/
	$(hide) $(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $@

INSTALLED_RECOVERYIMAGE_TARGET := $(PRODUCT_OUT)/recovery.img
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MINIGZIP) \
        $(MKBOOTIMG) \
		$(recovery_uncompressed_twrp_ramdisk) \
		$(recovery_kernel)
	@echo "----- Making recovery image ------"
	$(hide) rm -f $(PRODUCT_OUT)/ramdisk-recovery.cpio
	$(hide) mv $(recovery_uncompressed_twrp_ramdisk) $(PRODUCT_OUT)/ramdisk-recovery.cpio
	$(hide) $(MINIGZIP) < $(PRODUCT_OUT)/ramdisk-recovery.cpio > $(PRODUCT_OUT)/ramdisk-recovery.img
	$(hide) $(MKBOOTIMG) --kernel $(PRODUCT_OUT)/kernel --ramdisk $(PRODUCT_OUT)/ramdisk-recovery.img --cmdline "$(BOARD_KERNEL_CMDLINE)" --base $(BOARD_KERNEL_BASE) --pagesize $(BOARD_KERNEL_PAGESIZE) $(BOARD_MKBOOTIMG_ARGS) -o $(INSTALLED_RECOVERYIMAGE_TARGET)
	$(call pretty,"Made recovery image: $@")
