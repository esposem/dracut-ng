#!/bin/bash

NEWROOT=${NEWROOT:-'/sysroot'}

if [ -z "/new_root" ]; then
	echo "POPULATE: ROOT EXISTS" >> /output.txt
	exit 0
fi

mount -o remount,rw $NEWROOT
mkdir -p $NEWROOT/usr
chmod 755 $NEWROOT/usr
mkdir -p $NEWROOT/etc
echo -n "-F " > $NEWROOT/.autorelabel
