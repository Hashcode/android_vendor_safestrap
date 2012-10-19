#!/system/bin/sh
# By Hashcode
# Version: 3.00
PATH=/system/bin:/system/xbin

INSTALLPATH=$1
RECOVERY_DIR=/etc/safestrap
LOGFILE=$INSTALLPATH/action-install.log

chmod 755 $INSTALLPATH/busybox

echo "install path=$INSTALLPATH/install-files" > $LOGFILE
if [ -d $INSTALLPATH/install-files ]; then
	rm -r $INSTALLPATH/install-files >> $LOGFILE
fi

$INSTALLPATH/busybox unzip $INSTALLPATH/install-files.zip  -d $INSTALLPATH >> $LOGFILE
if [ ! -d $INSTALLPATH/install-files ]; then
	echo 'ERR: Zip file didnt extract correctly.  Installation aborted.' >> $LOGFILE
	exit 1
fi

if [ -f /dev/block/systemorig ]; then
	PRIMARYSYS=`$INSTALLPATH/busybox ls -l /dev/block/ | $INSTALLPATH/busybox grep systemorig | $INSTALLPATH/busybox tail -c 22`
else
	PRIMARYSYS=`$INSTALLPATH/busybox ls -l /dev/block/ | $INSTALLPATH/busybox grep system | $INSTALLPATH/busybox tail -c 22`
fi
CURRENTSYS=`$INSTALLPATH/busybox ls -l /dev/block/system | $INSTALLPATH/busybox tail -c 22`
# determine our active system, and mount/remount accordingly
if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	# alt-system, needs to mount original /system
	DESTMOUNT=$INSTALLPATH/system
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
	$INSTALLPATH/busybox chown 0.2000 $DESTMOUNT/bin/logwrapper.bin >> $LOGFILE
	$INSTALLPATH/busybox chmod 755 $DESTMOUNT/bin/logwrapper.bin >> $LOGFILE
fi
$INSTALLPATH/busybox rm $DESTMOUNT/bin/logwrapper >> $LOGFILE
$INSTALLPATH/busybox cp -f $INSTALLPATH/install-files/bin/logwrapper $DESTMOUNT/bin >> $LOGFILE
$INSTALLPATH/busybox chown 0.2000 $DESTMOUNT/bin/logwrapper >> $LOGFILE
$INSTALLPATH/busybox chmod 755 $DESTMOUNT/bin/logwrapper >> $LOGFILE

# delete any existing /system/etc/safestrap dir
if [ -d "$DESTMOUNT$RECOVERY_DIR" ]; then
	$INSTALLPATH/busybox rm -rf $DESTMOUNT$RECOVERY_DIR >> $LOGFILE
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
$INSTALLPATH/busybox cp -R $INSTALLPATH/install-files$RECOVERY_DIR $DESTMOUNT/etc >> $LOGFILE
$INSTALLPATH/busybox chown 0.2000 $DESTMOUNT$RECOVERY_DIR/* >> $LOGFILE
$INSTALLPATH/busybox chmod 755 $DESTMOUNT$RECOVERY_DIR/* >> $LOGFILE

# determine our active system, and umount/remount accordingly
if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	# if we're in 2nd-system then re-enable safe boot
	$INSTALLPATH/busybox touch $DESTMOUNT$RECOVERY_DIR/flags/alt_system_mode >> $LOGFILE

	$INSTALLPATH/busybox umount $DESTMOUNT >> $LOGFILE
	$INSTALLPATH/busybox rmdir $DESTMOUNT >> $LOGFILE
else
	$INSTALLPATH/busybox mount -o ro,remount $DESTMOUNT >> $LOGFILE
fi

