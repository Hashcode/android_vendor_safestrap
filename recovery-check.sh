#!/system/bin/sh
# By Hashcode
# Version: 0.90
PATH=/system/bin:/system/xbin
INSTALLPATH=$1
PRIMARYSYS=/dev/block/mmcblk1p21
vers=0
recmode=
altbootmode=0

CURRENTSYS=`$INSTALLPATH/busybox ls -l /dev/block/system | $INSTALLPATH/busybox tail -c 22`
if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	# alt-system, needs to mount original /system
	DESTMOUNT=$INSTALLPATH/system
	if [ ! -d "$DESTMOUNT" ]; then
		$INSTALLPATH/busybox mkdir $DESTMOUNT
	fi
	$INSTALLPATH/busybox mount -t ext3 $PRIMARYSYS $DESTMOUNT
else
	DESTMOUNT=/system
fi

if [ -f "$DESTMOUNT/etc/recovery/flags/version" ]; then
	vers=`$INSTALLPATH/busybox cat $DESTMOUNT/etc/recovery/flags/version`
fi
if [ -f "$DESTMOUNT/etc/recovery/flags/recovery_mode" ]; then
	recmode=`$INSTALLPATH/busybox cat $DESTMOUNT/etc/recovery/flags/recovery_mode`
fi
if [ -f "$DESTMOUNT/etc/recovery/flags/alt_system_mode" ]; then
	altbootmode=1
fi
echo "$vers:$recmode:$altbootmode"

if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	$INSTALLPATH/busybox umount $DESTMOUNT
fi

