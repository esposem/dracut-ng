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
if mount | grep -q "on /etc"; then
	echo "ETC ALREADY MOUNTED"
	exit 0
else
	echo "NOW ETC MOUNTED"
	mount --bind $NEWROOT/usr/etc/ $NEWROOT/etc
fi

# TODO: temp until root part encr
# mount -o remount,rw $NEWROOT
# mkdir -p $NEWROOT/.overlay/upper $NEWROOT/.overlay/work
# $NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay
# $NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay/upper
# $NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/.overlay/work

# # Create new /usr partition in /run/usr
# mkdir -p /run/usr
# # necessary to move in /run/usr
# mount --make-private $NEWROOT
# # move
# mount --move $NEWROOT/usr/ /run/usr
# # put overlay to make /usr rw
# mount -t overlay overlay -o lowerdir=/run/usr,upperdir=$NEWROOT/.overlay/upper,workdir=$NEWROOT/.overlay/work $NEWROOT/usr

# cat /etc/cloud/cloud.cfg.d/99-custom-user.cfg
# #cloud-config
# users:
#   - name: ema
#     gecos: "New Root User"
#     groups: sudo
#     shell: /bin/bash
#     sudo: ["ALL=(ALL) NOPASSWD:ALL"]
#     lock_passwd: false
#     passwd: $6$YqdSxNZrdrCSQ67c$oWbjF3aodcc1AuDM9.cLwQqFQ/bsoZiJ8AM0lzCAayyyOvooKyOGzMJ172U/z.wR9sOStbTHH95OKWSBJckQO1
