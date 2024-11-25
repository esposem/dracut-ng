. /lib/dracut-lib.sh

# Assumption: verity has been installed as root-x86-64-verity partition (if it's linux-generic, then systemd-repart only enlarges it)

# 0 install necessary stuff (in dracut module)
# TODO: why are they not included in dracut systemd-repart? They are needed by systemd-repart to format the partition...
inst_multiple -o mkfs.btrfs mkfs.ext4 mkfs.xfs

# 1 create/get the key. In this case, we assume it is in /sysroot.
# TODO: find another solution for this
# mount -o remount,rw /sysroot
# echo -n "redhat123" > /sysroot/root/luks-password
# OR create it every time in initramfs
# echo -n "redhat123" > /root/luks-password
mkdir -p /etc/cryptsetup-keys.d
echo -n "redhat123" > /etc/cryptsetup-keys.d/decrypted.key

# 2 create the partition on boot. Only needed at first boot
mkdir /etc/repart.d
echo -n "[Partition]
Type=linux-generic
Format=ext4
Encrypt=key-file
MakeDirectories=/work /upper" > /etc/repart.d/encr.conf
cat /etc/repart.d/encr.conf

systemd-repart --dry-run=no --key-file=/sysroot/etc/cryptsetup-keys.d/decrypted.key --no-pager --definitions=/etc/repart.d


# 3 mount. Done at each boot, because the original root fs doesn't contain any entry on /etc/crypttab, since it cannot be known before the partition is created, and we cannot write in the root disk anyways (it's ro :/ ).
# TODO: How to figure PARTUUID on the second boot?
DEVICE=`blkid -t PARTUUID=$PARTUUID -o device`
NEWROOT="/sysroot"

ENCR_PART=data
DEVICE=/dev/vda4

/usr/lib/systemd/systemd-cryptsetup attach decrypted $DEVICE /sysroot/etc/cryptsetup-keys.d/decrypted.key
mkdir -p /run/$ENCR_PART
mount /dev/mapper/decrypted /run/$ENCR_PART

/sysroot/usr/bin/chcon system_u:object_r:root_t:s0 /run/$ENCR_PART/upper
/sysroot/usr/bin/chcon system_u:object_r:root_t:s0 /run/$ENCR_PART/work

# 4 mount overlay. Done at each boot.
mkdir /run/oldroot
mount --make-private /
mount --make-private $NEWROOT
mount --move $NEWROOT /run/oldroot
mount -t overlay overlay -o lowerdir=/run/oldroot,upperdir=/run/$ENCR_PART/upper,workdir=/run/$ENCR_PART/work $NEWROOT


# 5 populate crypttab. Only needed at first boot.
# FSUUID=`blkid -t PARTUUID=$PARTUUID -s UUID -o value`

# echo "decrypted UUID=$FSUUID - x-initrd.attach" > /etc/crypttab
# /sysroot/usr/bin/chcon system_u:object_r:etc_t:s0 $NEWROOT/etc/crypttab

# echo "/dev/mapper/decrypted /data	ext4	defaults,x-initrd.mount,nofail 0 2" >> /etc/fstab
# /sysroot/usr/bin/chcon system_u:object_r:etc_t:s0 $NEWROOT/etc/fstab
