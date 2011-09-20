#!/system/bin/sh
# By Hashcode
# Version: 0.88
PATH=/system/bin:/system/xbin
LOGFILE=/data/action-install.log
INSTALLPATH=$1
PRIMARYSYS=/dev/block/mmcblk1p21

echo "install path=$INSTALLPATH/install-files" > $LOGFILE
if [ -d $INSTALLPATH/install-files ]; then
	rm -r $INSTALLPATH/install-files >> $LOGFILE
fi

busybox_loc = `command -v busybox`
command -v busybox >/dev/null && busybox_check=1 || busybox_check=0
if [ ! "$busybox_check"="1" ]; then
	echo 'Busybox required for this installation.  Please copy install-files/system/bin/busybox to your PATH.  Installation aborted.' >> $LOGFILE
	exit 1
fi
command -v busybox which >/dev/null && busybox_check=1 || busybox_check=0
if [ ! "$busybox_check"="1" ]; then
	echo 'Busybox does not contain the which applet.  Please copy install-files/system/bin/busybox to your PATH.  Installation aborted.' >> $LOGFILE
	exit 1
fi


$INSTALLPATH/busybox tar -xf $INSTALLPATH/install-files.tar -C $INSTALLPATH >> $LOGFILE
if [ ! -d $INSTALLPATH/install-files ]; then
	echo 'Error extracting tar file.  Aborting.' >> $LOGFILE
	exit 1
fi

CURRENTSYS=`$INSTALLPATH/busybox ls -l /dev/block/system | $INSTALLPATH/busybox tail -c 22`
# determine our active system, and mount/remount accordingly
if [ ! "$CURRENTSYS"="$PRIMARYSYS" ]; then
	# alt-system, needs to mount original /system
	DESTMOUNT=/data/local/tmp/system
	if [ ! -d "$DESTMOUNT" ]; then
		toolbox mkdir $DESTMOUNT
		toolbox chmod 755 $DESTMOUNT
	fi
	toolbox busybox mount -t ext3 $PRIMARYSYS $DESTMOUNT >> $LOGFILE
else
	DESTMOUNT=/system
	sync
	toolbox mount -o remount,rw /dev/null $DESTMOUNT >> $LOGFILE
fi

# check for a logwrapper.orig file and if there isn't one make a backup
if [ ! -f "$DESTMOUNT/bin/logwrapper.orig" ]; then
	# check for the bootstrapper backup of logwrapper, and back that up instead of the bootstrapper file...
	# *sigh*
	if [ -f "$DESTMOUNT/bin/logwrapper.bin" ]; then
		cp $DESTMOUNT/bin/logwrapper.bin $DESTMOUNT/bin/logwrapper.orig >> $LOGFILE
	else
		cp $DESTMOUNT/bin/logwrapper $DESTMOUNT/bin/logwrapper.orig >> $LOGFILE
	fi
fi
rm $DESTMOUNT/bin/logwrapper >> $LOGFILE
cp $INSTALLPATH/install-files/system/bin/logwrapper $DESTMOUNT/bin >> $LOGFILE
toolbox chown root.shell $DESTMOUNT/bin/logwrapper >> $LOGFILE
toolbox chmod 755 $DESTMOUNT/bin/logwrapper >> $LOGFILE

# check for a loadpreinstalls.sh.bak file and if there isn't one make a backup
# recreate the file so that our /preinstall mount doesn't get re-written all the time
if [ ! -f "$DESTMOUNT/bin/loadpreinstalls.sh.bak" ]; then
	cp $DESTMOUNT/bin/loadpreinstalls.sh $DESTMOUNT/bin/loadpreinstalls.sh.bak >> $LOGFILE
fi
cp $INSTALLPATH/install-files/system/bin/loadpreinstall.sh $DESTMOUNT/bin >> $LOGFILE

cp $INSTALLPATH/install-files/system/bin/2nd-init $DESTMOUNT/bin >> $LOGFILE
toolbox chown root.shell $DESTMOUNT/bin/2nd-init >> $LOGFILE
toolbox chmod 755 $DESTMOUNT/bin/2nd-init >> $LOGFILE

if [ -f "$DESTMOUNT/xbin/taskset" ]; then
	rm $DESTMOUNT/xbin/taskset >> $LOGFILE
fi
cp $INSTALLPATH/install-files/system/xbin/taskset $DESTMOUNT/xbin >> $LOGFILE
toolbox chown root.shell $DESTMOUNT/xbin/taskset >> $LOGFILE
toolbox chmod 755 $DESTMOUNT/xbin/taskset >> $LOGFILE

# we create symlinks for cp and mount in xbin for the bootup into 2nd-init
if [ -f "$DESTMOUNT/xbin/cp" ]; then
	rm $DESTMOUNT/xbin/cp >> $LOGFILE
fi
ln -s $busybox_loc $DESTMOUNT/xbin/cp >> $LOGFILE

if [ -f "$DESTMOUNT/xbin/mount" ]; then
	rm $DESTMOUNT/xbin/mount >> $LOGFILE
fi
ln -s $busybox_loc $DESTMOUNT/xbin/mount

# if the user doesn't have an /etc/rootfs dir we setup these as defaults for ROM booting.
# these files come preloaded on each rom in /system/etc/rootfs
#if [ ! -d "$INSTALLPATH/$SYS_MOUNT/etc/rootfs" ]; then
#	mkdir /system/etc/rootfs
#	toolbox chown root.shell /system/etc/rootfs >> $LOGFILE
#	toolbox chmod 644 /system/etc/rootfs >> $LOGFILE
#	cp $INSTALLPATH/install-files/system/etc/rootfs/* /system/etc/rootfs >> $LOGFILE
#	toolbox chown root.shell /system/etc/rootfs/* >> $LOGFILE
#	toolbox chmod 644 /system/etc/rootfs/* >> $LOGFILE
#fi

# delete any existing /system/etc/recovery dir
if [ -d "$DESTMOUNT/etc/recovery" ]; then
	/system/bin/rm -r $DESTMOUNT/etc/recovery >> $LOGFILE
fi
# extract the new recovery dir to /preinstall
$INSTALLPATH/busybox cp -R $INSTALLPATH/install-files/system/recovery $DESTMOUNT/etc >> $LOGFILE

sync

# determine our active system, and umount/remount accordingly
if [ ! "$CURRENTSYS"="$PRIMARYSYS" ]; then
	toolbox umount $DESTMOUNT >> $LOGFILE
	toolbox rmdir $DESTMOUNT
else
	toolbox mount -o ro,remount /dev/null $DESTMOUNT >> $LOGFILE
fi

