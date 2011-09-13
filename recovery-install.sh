#!/system/bin/sh
PATH=/system/bin:/system/xbin

busybox_loc=`busybox which busybox`
if [ ! -f "$busybox_loc" ]; then
	echo 'Busybox required for this installation.  Please copy install-files/system/bin/busybox to your PATH.  Installation aborted.'
	exit
fi

if [ -d install-files ]; then
	rm -r install-files
fi
$busybox_loc tar -zxf install-files.tar.gz
toolbox mount -o remount,rw /dev/null /system
if [ ! -f "/system/bin/logwrapper.orig" ]; then
	cp /system/bin/logwrapper /system/bin/logwrapper.orig
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
	cp -r install-files/system/etc/* /system/etc
	chown -r root.shell /system/etc/rootfs
	chmod -r 644 /system/etc/rootfs
fi
toolbox mount -o ro,remount /dev/null /system

toolbox mount -o remount,rw /dev/null /preinstall
if [ -d "/preinstall/recovery" ]; then
	/system/bin/rm -r /preinstall/recovery
fi
cp -r install-files/preinstall/recovery /preinstall
$busybox_loc touch /data/.recovery_mode
toolbox mount -o ro,remount /dev/null /preinstall

