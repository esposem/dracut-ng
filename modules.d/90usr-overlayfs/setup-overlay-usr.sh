#!/bin/bash
. /lib/dracut-lib.sh

NEWROOT=${NEWROOT:-'/sysroot'}

# TODO: temp until root part encr
mount -o remount,rw /sysroot
mkdir -p $NEWROOT/.overlay/upper $NEWROOT/.overlay/work
$NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay
$NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay/upper
$NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay/work

# Create new /usr partition in /run/usr
mkdir -p /run/usr
# necessary to move in /run/usr
mount --make-private $NEWROOT
# move
mount --move $NEWROOT/usr/ /run/usr
# put overlay to make /usr rw
mount -t overlay overlay -o lowerdir=/run/usr,upperdir=$NEWROOT/.overlay/upper,workdir=$NEWROOT/.overlay/work $NEWROOT/usr
