#!/bin/bash
. /lib/dracut-lib.sh

NEWROOT=${NEWROOT:-'/sysroot'}



# # Check if $NEWROOT/etc exists
# if [ -d "$NEWROOT/etc" ]; then
#     # Check if /etc contains any files
#     if ls $NEWROOT/etc/* 1> /dev/null 2>&1; then
#         exit 0
#     fi
# fi

# mkdir -p $NEWROOT/etc
# if mount | grep -q "on /etc"; then
# 	echo "ETC ALREADY MOUNTED"
# 	exit 0
# fi

# echo "NOW ETC MOUNTED"
# mount --bind $NEWROOT/usr/etc/ $NEWROOT/etc

if ! [ -z "/new_root" ]; then
	echo "OVERLAY: COPY FILES and CREATE ROOT" >> /output.txt
	cp -a $NEWROOT/usr/etc/* $NEWROOT/etc

	systemd-sysusers --root $NEWROOT
	systemd-tmpfiles --root $NEWROOT --create
fi


# TODO: temp until root part encr
# mount -o remount,rw $NEWROOT
# mkdir -p $NEWROOT/.overlay/upper $NEWROOT/.overlay/work
# $NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay
# $NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay/upper
# $NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay/work

# Create new /usr partition in /run/usr
mkdir -p /run/usr
# necessary to move in /run/usr
mount --make-private $NEWROOT
# move
mount --move $NEWROOT/usr/ /run/usr
# put overlay to make /usr rw
mount -t overlay overlay -o lowerdir=/run/usr,upperdir=$NEWROOT/.overlay/upper,workdir=$NEWROOT/.overlay/work $NEWROOT/usr

chmod 755 $NEWROOT/usr