#!/system/bin/sh
# By Hashcode
# Version: 0.85
PATH=/system/bin:/system/xbin
LOGFILE=/data/action-install.log
INSTALLPATH=$1

echo "install path=$INSTALLPATH/install-files" > $LOGFILE
if [ -d $INSTALLPATH/install-files ]; then
	rm -r $INSTALLPATH/install-files >> $LOGFILE
fi

busybox_loc=`busybox which busybox`
if [ ! -f "$busybox_loc" ]; then
	echo 'Busybox required for this installation.  Please copy install-files/system/bin/busybox to your PATH.  Installation aborted.' >> $LOGFILE
	exit
fi

$INSTALLPATH/busybox tar -xf $INSTALLPATH/install-files.tar -C $INSTALLPATH >> $LOGFILE
if [ ! -d $INSTALLPATH/install-files ]; then
	echo 'Error extracting tar file.  Aborting.' >> $LOGFILE
	exit
fi

toolbox mount -o remount,rw /dev/null /system >> $LOGFILE

# check for a logwrapper.orig file and if there isn't one make a backup
if [ ! -f "/system/bin/logwrapper.orig" ]; then
	# check for the bootstrapper backup of logwrapper, and back that up instead of the bootstrapper file...
	# *sigh*
	if [ -f "/system/bin/logwrapper.bin" ]; then
		cp /system/bin/logwrapper.bin /system/bin/logwrapper.orig >> $LOGFILE
	else
		cp /system/bin/logwrapper /system/bin/logwrapper.orig >> $LOGFILE
	fi
fi

rm /system/bin/logwrapper >> $LOGFILE
cp $INSTALLPATH/install-files/system/bin/logwrapper /system/bin >> $LOGFILE
toolbox chown root.shell /system/bin/logwrapper >> $LOGFILE
toolbox chmod 755 /system/bin/logwrapper >> $LOGFILE

cp $INSTALLPATH/install-files/system/bin/2nd-init /system/bin >> $LOGFILE
toolbox chown root.shell /system/bin/2nd-init >> $LOGFILE
toolbox chmod 755 /system/bin/2nd-init >> $LOGFILE

if [ -f "/system/xbin/taskset" ]; then
	rm /system/xbin/taskset >> $LOGFILE
fi
cp $INSTALLPATH/install-files/system/xbin/taskset /system/xbin >> $LOGFILE
toolbox chown root.shell /system/xbin/taskset >> $LOGFILE
toolbox chmod 755 /system/xbin/taskset >> $LOGFILE

# we create symlinks for cp and mount in xbin for the bootup into 2nd-init
if [ -f "/system/xbin/cp" ]; then
	rm /system/xbin/cp >> $LOGFILE
fi
ln -s $busybox_loc /system/xbin/cp >> $LOGFILE

if [ -f "/system/xbin/mount" ]; then
	rm /system/xbin/mount >> $LOGFILE
fi
ln -s $busybox_loc /system/xbin/mount

# if the user doesn't have an /etc/rootfs dir we setup these as defaults for ROM booting.
if [ ! -d "/system/etc/rootfs" ]; then
	mkdir /system/etc/rootfs
	toolbox chown root.shell /system/etc/rootfs >> $LOGFILE
	toolbox chmod 644 /system/etc/rootfs >> $LOGFILE
	cp $INSTALLPATH/install-files/system/etc/rootfs/* /system/etc/rootfs >> $LOGFILE
	toolbox chown root.shell /system/etc/rootfs/* >> $LOGFILE
	toolbox chmod 644 /system/etc/rootfs/* >> $LOGFILE
fi
toolbox mount -o ro,remount /dev/null /system >> $LOGFILE


toolbox mount -o remount,rw /dev/null /preinstall >> $LOGFILE
# delete any existing /preinstall/recovery dir
if [ -d "/preinstall/recovery" ]; then
	/system/bin/rm -r /preinstall/recovery >> $LOGFILE
fi
# extract the new recovery dir to /preinstall
busybox cp -R $INSTALLPATH/install-files/preinstall/recovery /preinstall >> $LOGFILE
toolbox mount -o ro,remount /dev/null /preinstall >> $LOGFILE

