#!/bin/sh

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

getargbool 0 rd.overlayroot && root_overlayfs="yes"

ENCR_PART=data
NEWROOT=${NEWROOT:-"/sysroot"}
DEVICE=/dev/vda4 # TODO:

create_luks_partition() {
    mkdir /etc/repart.d
    echo -n "[Partition]
    Type=linux-generic
    Format=ext4
    Encrypt=tpm2
    MakeDirectories=/work /upper" > /etc/repart.d/encr.conf

    # TODO: in rhel, it requires this patch: https://github.com/systemd/systemd/pull/29596/commits/afeb49a4eccac92e43b6359a5d4269ba85320185
    systemd-repart --dry-run=no --no-pager --definitions=/etc/repart.d --tpm2-device=auto --tpm2-pcrs=7
}

attach_luks_partition() {
    /usr/lib/systemd/systemd-cryptsetup attach decrypted $DEVICE - "tpm2-device=auto tpm2-pcrs=7"
    mkdir -p /run/$ENCR_PART
    mount /dev/mapper/decrypted /run/$ENCR_PART

    chcon system_u:object_r:root_t:s0 /run/$ENCR_PART/upper
    chcon system_u:object_r:root_t:s0 /run/$ENCR_PART/work
}

mount_overlay() {
    mkdir /run/oldroot
    mount --make-private /
    mount --make-private $NEWROOT
    mount --move $NEWROOT /run/oldroot
    mount -t overlay overlay -o lowerdir=/run/oldroot,upperdir=/run/$ENCR_PART/upper,workdir=/run/$ENCR_PART/work $NEWROOT
}

if [ ! -z ${root_overlayfs} ]; then
	create_luks_partition
    attach_luks_partition
    mount_overlay
fi

