#!/bin/bash

NEWROOT=${NEWROOT:-'/sysroot'}

ROOT=$(lsblk -o NAME,TYPE,PARTTYPE --json | jq -r '.blockdevices[] | select(.type == "disk") | .children[] | select(.parttype == "4f68bce3-e8cd-4db1-96e7-fbcaf984b709")')
echo "ROOT $ROOT" > /output.txt

DNAME=$(lsblk -o NAME,TYPE --json | jq -r '.blockdevices[] | select(.type == "disk") | .name ')
echo "DNAME $DNAME" >> /output.txt
# DNAME=vda

if ! [ -z "${ROOT:-}" ]; then
	echo "ROOT EXISTS" >> /output.txt
	# mount /dev/$UNAME $NEWROOT/usr
	exit 0
fi

echo "NO ROOT" >> /output.txt

echo "" > /new_root

#### root (encrypted) in initramfs
mkdir /etc/repart.d
echo -n "[Partition]
Type=root
Format=ext4
Encrypt=tpm2" > /etc/repart.d/encr.conf

# REPART_OUT=$(systemd-repart /dev/$DNAME --dry-run=no --no-pager --definitions=etc/repart.d --tpm2-device=auto --tpm2-pcrs=7 --json pretty | jq -r '.[] | select(.type == "root-x86-64") | .activity')
systemd-repart /dev/$DNAME --dry-run=no --no-pager --definitions=/etc/repart.d --tpm2-device=auto --tpm2-pcrs=7 # --factory-reset=yes
# sleep 5
# TODO: this is only for writable /usr
# mount /dev/mapper/root $NEWROOT
# mount -o remount,rw $NEWROOT
######
# mkdir -p $NEWROOT/usr
# mkdir -p $NEWROOT/etc

# TODO: this is only for writable /usr
# mount /dev/$UNAME $NEWROOT/usr
######
# systemd-sysusers --root $NEWROOT
# systemd-tmpfiles --root $NEWROOT --create

# echo -n "-F " > $NEWROOT/.autorelabel
# $NEWROOT/usr/bin/chcon system_u:object_r:root_t:s0 $NEWROOT/*
# mkdir $NEWROOT/proc $NEWROOT/dev $NEWROOT/sys
# mkdir $NEWROOT/var/log/audit