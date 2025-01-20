#!/bin/bash

NEWROOT=${NEWROOT:-'/sysroot'}

ROOT=$(lsblk -o NAME,TYPE,PARTTYPE --json | jq -r '.blockdevices[] | select(.type == "disk") | .children[] | select(.parttype == "4f68bce3-e8cd-4db1-96e7-fbcaf984b709")')
echo "ROOT $ROOT" > /output.txt

DNAME=$(lsblk -o NAME,TYPE --json | jq -r '.blockdevices[] | select(.type == "disk") | .name ')
echo "DNAME $DNAME" >> /output.txt

if ! [ -z "${ROOT:-}" ]; then
	echo "ROOT EXISTS" >> /output.txt
	# mount /dev/$UNAME $NEWROOT/usr
	exit 0
fi

echo "NO ROOT" >> /output.txt

echo "" > /new_root

mkdir /etc/repart.d
echo -n "[Partition]
Type=root
Format=ext4
Encrypt=tpm2" > /etc/repart.d/encr.conf

# REPART_OUT=$(systemd-repart /dev/$DNAME --dry-run=no --no-pager --definitions=etc/repart.d --tpm2-device=auto --tpm2-pcrs=7 --json pretty | jq -r '.[] | select(.type == "root-x86-64") | .activity')
systemd-repart /dev/$DNAME --dry-run=no --no-pager --definitions=/etc/repart.d --tpm2-device=auto --tpm2-pcrs=7 # --factory-reset=yes

# TODO: this is only for writable /usr
# mount /dev/mapper/root $NEWROOT
######

# TODO: this is only for writable /usr
# mount /dev/$UNAME $NEWROOT/usr
######