#!/system/bin/sh

busybox_loc=`busybox which busybox`
if [ "$busybox_loc" != "" ]; then
	if [ -d install-files ]; then
		$busybox_loc rm -r install-files
	fi
	$busybox_loc tar -zxf install-files.tar.gz
	$busybox_loc mount -o remount,rw /system
	if [ ! -f "/system/bin/logwrapper.orig" ]; then
		$busybox_loc cp /system/bin/logwrapper /system/bin/logwrapper.orig
	fi
	cp install-files/system/bin/logwrapper /system/bin
	chown root.shell /system/bin/logwrapper
	chmod 755 /system/bin/logwrapper
	cp install-files/system/bin/2nd-init /system/bin
	chown root.shell /system/bin/2nd-init
	chmod 755 /system/bin/2nd-init
	if [ -f "/system/xbin/taskset" ]; then
		rm /system/xbin/taskset
	fi
	cp install-files/system/xbin/taskset /system/xbin
	chown root.shell /system/xbin/taskset
	chmod 755 /system/xbin/taskset
	if [ -f "/system/xbin/cp" ]; then
		rm /system/xbin/cp
	fi
	ln -s $busybox_loc /system/xbin/cp
	if [ -f "/system/xbin/mount" ]; then
		rm /system/xbin/mount
	fi
	ln -s $busybox_loc /system/xbin/mount
	if [ ! -d "/system/etc/rootfs" ]; then
		cp install-files/system/etc/* /system/etc
		chown -R root.shell /system/etc/rootfs
		chmod -R 644 /system/etc/rootfs
	fi
	$busybox_loc mount -o ro,remount /system

	$busybox_loc mount -o remount,rw /preinstall
	if [ -d "/preinstall/recovery" ]; then
		rm -r /preinstall/recovery
	fi
	cp -r install-files/preinstall/recovery /preinstall
	$busybox_loc mount -o ro,remount /preinstall
else
	echo 'Busybox required for this installation.  Please copy install-files/system/bin/busybox to your PATH.  Installation aborted.'
fi
