#!/system/bin/sh
# By Hashcode
# Version: 1.09
PATH=/system/bin:/system/xbin
RECOVERY_DIR=/etc/safestrap
PRIMARYSYS=/dev/block/mmcblk1p20
INSTALLPATH=$1
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

if [ -f "$DESTMOUNT$RECOVERY_DIR/flags/version" ]; then
	vers=`$INSTALLPATH/busybox cat $DESTMOUNT$RECOVERY_DIR/flags/version`
fi
if [ -f "$DESTMOUNT$RECOVERY_DIR/flags/recovery_mode" ]; then
	recmode=`$INSTALLPATH/busybox cat $DESTMOUNT$RECOVERY_DIR/flags/recovery_mode`
fi
if [ -f "$DESTMOUNT$RECOVERY_DIR/flags/alt_system_mode" ]; then
	altbootmode=1
fi
echo "$vers:$recmode:$altbootmode"

if [ ! "$CURRENTSYS" = "$PRIMARYSYS" ]; then
	$INSTALLPATH/busybox umount $DESTMOUNT
fi

