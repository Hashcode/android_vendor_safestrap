#!/system/bin/sh
# By Hashcode
# Version: 0.88
PATH=/system/bin:/system/xbin
INSTALLPATH=$1
FILEMODE=$2
PRIMARYSYS=/dev/block/mmcblk1p21

CURRENTSYS=`$INSTALLPATH/busybox ls -l /dev/block/system | $INSTALLPATH/busybox tail -c 22`
if [ ! "$CURRENTSYS"="$PRIMARYSYS" ]; then
	# alt-system, needs to mount original /system
	DESTMOUNT=$INSTALLPATH/system
	if [ ! -d "$DESTMOUNT" ]; then
		$INSTALLPATH/busybox mkdir $DESTMOUNT
	fi
	$INSTALLPATH/busybox mount -t ext3 $PRIMARYSYS $DESTMOUNT
else
	DESTMOUNT=/system
	$INSTALLPATH/busybox mount -o remount,rw $DESTMOUNT
fi

if [ "$FILEMODE"="1" ]; then
	# create
	$INSTALLPATH/busybox touch $DESTMOUNT/etc/recovery/flags/altbootmode
else
	# delete
	$INSTALLPATH/busybox rm $DESTMOUNT/etc/recovery/flags/altbootmode
fi

if [ ! "$CURRENTSYS"="$PRIMARYSYS" ]; then
	$INSTALLPATH/busybox umount $DESTMOUNT
else
	$INSTALLPATH/busybox mount -o ro,remount $DESTMOUNT
fi

