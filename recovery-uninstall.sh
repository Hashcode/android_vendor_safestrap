#!/system/bin/sh
# By Hashcode
# Version: 0.88
PATH=/system/bin:/system/xbin
LOGFILE=/data/action-uninstall.log
PRIMARYSYS=/dev/block/mmcblk1p21

echo '' > $LOGFILE

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

if [ -f "$DESTMOUNT/bin/logwrapper.orig" ]; then
	cp $DESTMOUNT/bin/logwrapper.orig $DESTMOUNT/bin/logwrapper >> $LOGFILE
	toolbox chown root.shell $DESTMOUNT/bin/logwrapper >> $LOGFILE
	toolbox chmod 755 $DESTMOUNT/bin/logwrapper >> $LOGFILE
fi
if [ -f "$DESTMOUNT/bin/loadpreinstalls.sh.bak" ]; then
	cp $DESTMOUNT/bin/loadpreinstalls.sh.bak $DESTMOUNT/bin/loadpreinstall.sh >> $LOGFILE
	toolbox chown root.shell $DESTMOUNT/bin/loadpreinstall.sh >> $LOGFILE
	toolbox chmod 755 $DESTMOUNT/bin/loadpreinstall.sh >> $LOGFILE
fi
if [ -f "$DESTMOUNT/bin/2nd-init" ]; then
	rm $DESTMOUNT/bin/2nd-init >> $LOGFILE
fi
if [ -f "$DESTMOUNT/xbin/taskset" ]; then
	rm $DESTMOUNT/xbin/taskset >> $LOGFILE
fi
if [ -f "$DESTMOUNT/xbin/cp" ]; then
	rm $DESTMOUNT/xbin/cp >> $LOGFILE
fi
if [ -f "$DESTMOUNT/xbin/mount" ]; then
	rm $DESTMOUNT/xbin/mount >> $LOGFILE
fi
if [ -d "$DESTMOUNT/etc/recovery" ]; then
	toolbox rm -r $DESTMOUNT/etc/recovery >> $LOGFILE
fi

sync

# determine our active system, and umount/remount accordingly
if [ ! "$CURRENTSYS"="$PRIMARYSYS" ]; then
	toolbox umount $DESTMOUNT >> $LOGFILE
	toolbox rmdir $DESTMOUNT
else
	toolbox mount -o ro,remount /dev/null $DESTMOUNT >> $LOGFILE
fi



