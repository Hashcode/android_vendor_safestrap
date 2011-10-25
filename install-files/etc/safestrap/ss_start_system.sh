#!/system/bin/sh
# By: Hashcode and Edgan
# hijack.killall: Credit Cyanogenmod, Modified for Busybox
# Version: 1.0

PATH=/system/xbin:/system/bin
REC_FILE=/system/etc/recovery/flags/recovery_mode
ALT_SYSTEM_FILE=/system/etc/recovery/flags/alt_system_mode
RECOVERY_DIR=/system/etc/recovery
HIJACKED_PROP=ro.hijacked
HIJACKED=$(getprop $HIJACKED_PROP)
BOOTMODE=$(getprop ro.bootmode)
CHECK_BOOTMODE="bp-tools"

if [ "$HIJACKED" -eq "1" ]; then
	/system/bin/logwrapper.bin "$@"
	exit
fi

if [ -f "$ALT_SYSTEM_FILE" ] ; then
	setprop $HIJACKED_PROP 1

	# back out of init.rc as much as possible
	mount -o remount,rw rootfs

	mv /sbin/adbd /sbin/adbd.old

	busybox unzip -o $RECOVERY_DIR/2nd-init.zip -d /sbin
	cd /sbin
	ln -s recovery busybox
	cd /
	chmod 750 /sbin/*

	# mount preinstall and move /preinstall/etc/rootfs/* to /
	/sbin/busybox mount -t ext3 /dev/block/mmcblk1p23 /preinstall
	/sbin/busybox cp /preinstall/etc/rootfs/* /
	/sbin/busybox chmod 755 /init
	/sbin/busybox chmod 644 /default.prop
	/sbin/busybox chmod 755 /*.rc
	/sbin/busybox umount /preinstall

	/sbin/busybox umount -l /system

	/sbin/hijack.killall

	# mount/symlink point cleanup
	/sbin/rm /sdcard
	/sbin/rm /sdcard-ext
	/sbin/rmdir /osh
	/sbin/rm -r /mnt
	/sbin/rm /vendor
	/sbin/rm /d

	/sbin/taskset -p -c 0 1
	/sbin/busybox sync
	/sbin/taskset -c 0 /sbin/2nd-init
	exit
fi

/system/bin/logwrapper.bin "$@"

