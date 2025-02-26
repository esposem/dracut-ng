#!/bin/bash

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh
NEWROOT=${NEWROOT:-'/sysroot'}

if getargbool 0 create_root.overlay; then
	mount -o remount,rw $NEWROOT
	mkdir -p /run/usr
	mount --make-private $NEWROOT
	mount --move $NEWROOT/usr/ /run/usr
	mount -t overlay overlay -o lowerdir=/run/usr,upperdir=$NEWROOT/.overlay/upper,workdir=$NEWROOT/.overlay/work $NEWROOT/usr
	chmod 755 $NEWROOT/usr
	echo "OVERLAY: OVERLAY USR" >> /output.txt
fi

