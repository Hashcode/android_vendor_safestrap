#!/system/bin/sh

busybox_loc=`busybox which busybox`
if [ "$busybox_loc" = "" ]; then
	echo 'Busybox required for this installation.  Please copy install-files/system/bin/busybox to your PATH.  Installation aborted.'
	exit
else
	if [ -d install-files ]; then
		$busybox_loc rm -r install-files
	fi
	$busybox_loc tar -zxf install-files.tar.gz
	$busybox_loc mount -o remount,rw /system
	if [ ! -f "/system/bin/logwrapper.orig" ]; then
		/system/bin/cp /system/bin/logwrapper /system/bin/logwrapper.orig
	fi
	/system/bin/cp install-files/system/bin/logwrapper /system/bin
	/system/bin/chown root.shell /system/bin/logwrapper
	/system/bin/chmod 755 /system/bin/logwrapper
	/system/bin/cp install-files/system/bin/2nd-init /system/bin
	/system/bin/chown root.shell /system/bin/2nd-init
	/system/bin/chmod 755 /system/bin/2nd-init
	if [ -f "/system/xbin/taskset" ]; then
		rm /system/xbin/taskset
	fi
	/system/bin/cp install-files/system/xbin/taskset /system/xbin
	/system/bin/chown root.shell /system/xbin/taskset
	/system/bin/chmod 755 /system/xbin/taskset
	if [ -f "/system/xbin/cp" ]; then
		/system/bin/rm /system/xbin/cp
	fi
	/system/bin/ln -s $busybox_loc /system/xbin/cp
	if [ -f "/system/xbin/mount" ]; then
		/system/bin/rm /system/xbin/mount
	fi
	/system/bin/ln -s $busybox_loc /system/xbin/mount
	if [ ! -d "/system/etc/rootfs" ]; then
		/system/bin/cp -r install-files/system/etc/* /system/etc
		/system/bin/chown -r root.shell /system/etc/rootfs
		/system/bin/chmod -r 644 /system/etc/rootfs
	fi
	$busybox_loc mount -o ro,remount /system

	$busybox_loc mount -o remount,rw /preinstall
	if [ -d "/preinstall/recovery" ]; then
		/system/bin/rm -r /preinstall/recovery
	fi
	/system/bin/cp -r install-files/preinstall/recovery /preinstall
	$busybox_loc mount -o ro,remount /preinstall
fi
