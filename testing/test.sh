#!/system/bin/sh
# By: Hashcode and Edgan
# Version: 0.88
PATH=/system/xbin:/system/bin
REC_FILE=/system/etc/recovery/flags/recovery_mode
RECOVERY_DIR=/system/etc/recovery
BOOTMODE=$(getprop ro.bootmode)
CHECK_BOOTMODE="bp-tools"

# boot modes= ap-bp-bypass, bp-tools
# check the boot mode from the recovery file
if [ -f "$REC_FILE" ]; then
	CHECK_BOOTMODE=`cat $REC_FILE`
	echo "BOOTMODE=$CHECK_BOOTMODE"
fi
if [ "$BOOTMODE"="$CHECK_BOOTMODE" ]; then
	echo BP-tools!
else
	echo Not BP-tools!
fi
