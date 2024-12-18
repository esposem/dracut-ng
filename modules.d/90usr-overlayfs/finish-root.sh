#!/bin/bash
. /lib/dracut-lib.sh

NEWROOT=${NEWROOT:-'/sysroot'}

# if it's newly created root, copy the files and init the system (it's rw)
if [ -e "/new_root" ]; then
	echo "OVERLAY: COPY FILES and CREATE ROOT" >> /output.txt
	cp -aZ $NEWROOT/usr/etc/* $NEWROOT/etc

	systemd-sysusers --root $NEWROOT
	systemd-tmpfiles --root $NEWROOT --create
fi

mount -o remount,rw $NEWROOT #TODO: this might be a problem
mkdir -p /run/usr
mount --make-private $NEWROOT
mount --move $NEWROOT/usr/ /run/usr
mount -t overlay overlay -o lowerdir=/run/usr,upperdir=$NEWROOT/.overlay/upper,workdir=$NEWROOT/.overlay/work $NEWROOT/usr
chmod 755 $NEWROOT/usr
