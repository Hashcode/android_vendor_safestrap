#!/system/bin/sh
# By Hashcode
# Version: 0.93
PATH=/system/bin:/system/xbin
INSTALLPATH=$1
LOGFILE=$INSTALLPATH/action-install.log
PRIMARYSYS=/dev/block/mmcblk1p21

echo "install path=$INSTALLPATH/install-files" > $LOGFILE
if [ -d $INSTALLPATH/install-files ]; then
	rm -r $INSTALLPATH/install-files >> $LOGFILE
fi

busybox_loc = `command -v busybox`
command -v busybox >/dev/null && busybox_check=1 || busybox_check=0
if [ ! "$busybox_check" -eq "1" ]; then
	echo "ERR: Busybox required for this installation.  Please copy $INSTALLPATH/install-files/system/bin/busybox to your PATH.  Installation aborted." >> $LOGFILE
	exit 1
fi
command -v busybox rm >/dev/null && busybox_check=1 || busybox_check=0
if [ ! "$busybox_check" -eq "1" ]; then
	echo "ERR: Your busybox does not contain the \"rm\" applet.  Please copy $INSTALLPATH/install-files/system/bin/busybox to your PATH.  Installation aborted." >> $LOGFILE
	exit 1
fi
command -v busybox ln >/dev/null && busybox_check=1 || busybox_check=0
if [ ! "$busybox_check" -eq "1" ]; then
	echo "ERR: Your busybox does not contain the \"ln\" applet.  Please copy $INSTALLPATH/install-files/system/bin/busybox to your PATH.  Installation aborted." >> $LOGFILE
	exit 1
fi
command -v busybox umount >/dev/null && busybox_check=1 || busybox_check=0
if [ ! "$busybox_check" -eq "1" ]; then
	echo "ERR: Your busybox does not contain the \"umount\" applet.  Please copy $INSTALLPATH/install-files/system/bin/busybox to your PATH.  Installation aborted." >> $LOGFILE
	exit 1
fi

$INSTALLPATH/busybox tar -xf $INSTALLPATH/install-files.tar -C $INSTALLPATH >> $LOGFILE
if [ ! -d $INSTALLPATH/install-files ]; then
	echo 'ERR: Tar file didnt extract correctly.  Installation aborted.' >> $LOGFILE
	exit 1
fi

CURRENTSYS=`$INSTALLPATH/busybox ls -l /dev/block/system | $INSTALLPATH/busybox tail -c 22`
# determine our active system, and mount/remount accordingly
if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	# alt-system, needs to mount original /system
	DESTMOUNT=/data/local/tmp/system
	if [ ! -d "$DESTMOUNT" ]; then
		$INSTALLPATH/busybox mkdir $DESTMOUNT
		$INSTALLPATH/busybox chmod 755 $DESTMOUNT
	fi
	$INSTALLPATH/busybox mount -t ext3 $PRIMARYSYS $DESTMOUNT >> $LOGFILE
else
	DESTMOUNT=/system
	sync
	$INSTALLPATH/busybox mount -o remount,rw $DESTMOUNT >> $LOGFILE
fi

# check for a logwrapper.bin file and its not there, make a copy
if [ ! -f "$DESTMOUNT/bin/logwrapper.bin" ]; then
	$INSTALLPATH/busybox cp $DESTMOUNT/bin/logwrapper $DESTMOUNT/bin/logwrapper.bin >> $LOGFILE
fi
$INSTALLPATH/busybox rm $DESTMOUNT/bin/logwrapper >> $LOGFILE
$INSTALLPATH/busybox cp -f $INSTALLPATH/install-files/bin/logwrapper $DESTMOUNT/bin >> $LOGFILE
$INSTALLPATH/busybox chown 0.2000 $DESTMOUNT/bin/logwrapper >> $LOGFILE
$INSTALLPATH/busybox chmod 755 $DESTMOUNT/bin/logwrapper >> $LOGFILE

# delete any existing /system/etc/safestrap dir
if [ -d "$DESTMOUNT/etc/safestrap" ]; then
	$INSTALLPATH/busybox rm -rf $DESTMOUNT/etc/safestrap >> $LOGFILE
fi
# delete any existing /system/etc/recovery dir
if [ -d "$DESTMOUNT/etc/recovery" ]; then
	$INSTALLPATH/busybox rm -rf $DESTMOUNT/etc/recovery >> $LOGFILE
fi
# delete any existing /system/etc/rootfs dir
if [ -d "$DESTMOUNT/etc/rootfs" ]; then
	$INSTALLPATH/busybox rm -rf $DESTMOUNT/etc/rootfs >> $LOGFILE
fi
# extract the new dirs to /system
$INSTALLPATH/busybox cp -R $INSTALLPATH/install-files/safestrap $DESTMOUNT/etc >> $LOGFILE
$INSTALLPATH/busybox chown 0.2000 $DESTMOUNT/etc/safestrap/* >> $LOGFILE
$INSTALLPATH/busybox chmod 755 $DESTMOUNT/etc/safestrap/* >> $LOGFILE
$INSTALLPATH/busybox cp -R $INSTALLPATH/install-files/etc/recovery $DESTMOUNT/etc >> $LOGFILE
$INSTALLPATH/busybox cp -R $INSTALLPATH/install-files/etc/rootfs $DESTMOUNT/etc >> $LOGFILE

# determine our active system, and umount/remount accordingly
if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	# if we're in 2nd-system then re-enable safe boot
	$INSTALLPATH/busybox touch $DESTMOUNT/etc/recovery/flags/alt_system_mode >> $LOGFILE

	$INSTALLPATH/busybox umount $DESTMOUNT >> $LOGFILE
	$INSTALLPATH/busybox rmdir $DESTMOUNT >> $LOGFILE
else
	$INSTALLPATH/busybox mount -o ro,remount $DESTMOUNT >> $LOGFILE
fi

