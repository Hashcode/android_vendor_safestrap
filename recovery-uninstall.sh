#!/system/bin/sh
# By Hashcode
# Version: 1.09
PATH=/system/bin:/system/xbin
RECOVERY_DIR=/etc/safestrap
PRIMARYSYS=/dev/block/mmcblk1p21
INSTALLPATH=$1
LOGFILE=$INSTALLPATH/action-uninstall.log

echo '' > $LOGFILE

chmod 755 $INSTALLPATH/busybox
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

if [ -f "$DESTMOUNT/bin/logwrapper.bin" ]; then
	$INSTALLPATH/busybox cp -f $DESTMOUNT/bin/logwrapper.bin $DESTMOUNT/bin/logwrapper >> $LOGFILE
	$INSTALLPATH/busybox chown 0.2000 $DESTMOUNT/bin/logwrapper >> $LOGFILE
	$INSTALLPATH/busybox chmod 755 $DESTMOUNT/bin/logwrapper >> $LOGFILE
fi
if [ -d "$DESTMOUNT$RECOVERY_DIR" ]; then
	$INSTALLPATH/busybox rm -r $DESTMOUNT$RECOVERY_DIR >> $LOGFILE
fi

sync

# determine our active system, and umount/remount accordingly
if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	$INSTALLPATH/busybox umount $DESTMOUNT >> $LOGFILE
	$INSTALLPATH/busybox rmdir $DESTMOUNT
else
	$INSTALLPATH/busybox mount -o ro,remount $DESTMOUNT >> $LOGFILE
fi



