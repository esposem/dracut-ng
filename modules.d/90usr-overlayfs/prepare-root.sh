#!/bin/bash

NEWROOT=${NEWROOT:-'/sysroot'}

# if file does not exist, then we don't need to populate
if [ -e "/new_root" ]; then
	mount -o remount,rw $NEWROOT
	mkdir -p $NEWROOT/usr
	chmod 755 $NEWROOT/usr
	mkdir -p $NEWROOT/etc
	echo -n "-F " > $NEWROOT/.autorelabel
	echo "POPULATE: DONE" >> /output.txt
	exit 0
fi

echo "POPULATE: SKIPPED" >> /output.txt
