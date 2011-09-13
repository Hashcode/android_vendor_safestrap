#!/system/bin/sh

busybox_loc=`busybox which busybox`
if [ "$busybox_loc" != "" ]; then
	if [ -d CWRecovery ]; then
		$busybox_loc rm -r CWRecovery
	fi
	$busybox_loc tar -zxf CWRecovery.tar.gz
	$busybox_loc mount -o remount,rw /system
	if [ ! -f "/system/bin/logwrapper.orig" ]; then
		$busybox_loc cp /system/bin/logwrapper /system/bin/logwrapper.orig
	fi
	cp CWRecovery/system/bin/logwrapper /system/bin
	chown root.shell /system/bin/logwrapper
	chmod 755 /system/bin/logwrapper
	cp CWRecovery/system/bin/2nd-init /system/bin
	chown root.shell /system/bin/2nd-init
	chmod 755 /system/bin/2nd-init
	if [ -f "/system/xbin/taskset" ]; then
		rm /system/xbin/taskset
	fi
	cp CWRecovery/system/xbin/taskset /system/xbin
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
		cp -r CWRecovery/system/etc /system/etc
		chown -R root.shell /system/etc/rootfs
		chmod -R 644 /system/etc/rootfs
	fi
	$busybox_loc mount -o ro,remount /system

	$busybox_loc mount -o remount,rw /preinstall
	if [ -d "/preinstall/recovery" ]; then
		rm -r /preinstall/recovery
	fi
	cp -r CWRecovery/preinstall/recovery /preinstall
	$busybox_loc mount -o ro,remount /preinstall
else
	echo 'Busybox required for this installation.  Please copy CWRecovery/system/bin/busybox to your PATH.  Installation aborted.'
fi
