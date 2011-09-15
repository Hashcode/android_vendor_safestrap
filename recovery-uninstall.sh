#!/system/bin/sh
# By Hashcode
# Version: 0.85
PATH=/system/bin:/system/xbin
LOGFILE=/data/action-uninstall.log

echo '' > $LOGFILE
toolbox mount -o remount,rw /dev/null /system >> $LOGFILE
if [ -f "/system/bin/logwrapper.orig" ]; then
	cp /system/bin/logwrapper.orig /system/bin/logwrapper >> $LOGFILE
	toolbox chown root.shell /system/bin/logwrapper >> $LOGFILE
	toolbox chmod 755 /system/bin/logwrapper >> $LOGFILE
fi
if [ -f "/system/bin/2nd-init" ]; then
	rm /system/bin/2nd-init >> $LOGFILE
fi
if [ -f "/system/xbin/taskset" ]; then
	rm /system/xbin/taskset >> $LOGFILE
fi
if [ -f "/system/xbin/cp" ]; then
	rm /system/xbin/cp >> $LOGFILE
fi
if [ -f "/system/xbin/mount" ]; then
	rm /system/xbin/mount >> $LOGFILE
fi
toolbox mount -o ro,remount /dev/null /system

toolbox mount -o remount,rw /dev/null /preinstall
if [ -d "/preinstall/recovery" ]; then
	toolbox rm -r /preinstall/recovery >> $LOGFILE
fi
toolbox mount -o ro,remount /dev/null /preinstall

