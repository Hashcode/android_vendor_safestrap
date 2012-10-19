#!/sbin/bbx sh
PATH=/system/xbin:/system/bin:/sbin

fixReference()
{
	FIXBLK=$(/sbin/bbx cat /proc/partitions | /sbin/bbx grep ${2} | /sbin/bbx cut -c26-35 | /sbin/bbx sed s/\t*//)
	if [ "$FIXBLK" != "" ]; then
		/sbin/bbx sed s/$FIXBLK/${3}/ < ${1} > ${1}.bak
		RESULT=`echo $?`
		if [ $RESULT -eq 0 ]; then
			if [ -f ${1}.bak ]; then
				/sbin/bbx mv ${1}.bak ${1}
			fi
		else
			/sbin/rm ${1}.bak
		fi
	fi
}


# fix "old" style mounts
for f in ./init.*.rc
do
	fixReference "$f" system system
	fixReference "$f" userdata userdata
	fixReference "$f" cache cache
	fixReference "$f" pds pds
	# include translations for older SS2 style ROMs (preinstall / webtop used as system)
	fixReference "$f" preinstall system
	fixReference "$f" webtop system
done

