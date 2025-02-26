#!/bin/bash

type getarg > /dev/null 2>&1 || . /lib/dracut-lib.sh

NEWROOT=${NEWROOT:-'/sysroot'}

echo "#### PREPARE ROOT ####" >> /run/output.txt

if ! [ -e "/run/create_new_root" ]; then
	exit 0
fi

mkdir -p $NEWROOT/etc
# TODO: copy or overlay?
cp -aZ $NEWROOT/usr/etc/* $NEWROOT/etc

echo "CP /usr/etc into /etc" >> /run/output.txt

# get rid of root in /etc/fstab since it is referring to an old one
sed -i '\|^[^#]\+\s\+/\s\+|d' $NEWROOT/etc/fstab

echo "RM ROOT FSTAB" >> /run/output.txt
cat  $NEWROOT/etc/fstab >> /run/output.txt

mkdir -p /run/tmpfiles.d

# overlay files
echo "d /.overlay 700 root root -
A /.overlay - - - - system_u:object_r:root_t:s0
d /.overlay/upper 700 root root -
A /.overlay/upper - - - - system_u:object_r:root_t:s0
d /.overlay/work 700 root root -
A /.overlay/work - - - - system_u:object_r:root_t:s0" > /run/tmpfiles.d/create-missing-root.conf

# required to make audit happy
echo "d /var/log/audit 700 root root -
d /var/lib/rsyslog 700 root root -
A /var/log/audit - - - - system_u:object_r:auditd_log_t:s0" >> /run/tmpfiles.d/create-missing-root.conf

systemd-sysusers --root $NEWROOT
systemd-tmpfiles --root $NEWROOT --create
systemd-tmpfiles --root $NEWROOT --create /run/tmpfiles.d/create-missing-root.conf

# create symlinks
cd $NEWROOT
ln -s usr/lib lib
ln -s usr/lib64 lib64
ln -s usr/sbin sbin
ln -s usr/bin bin
cd -

# ls -Z $NEWROOT >> /run/output.txt

# chroot "$NEWROOT" /sbin/restorecon -R /
# setfiles -r $NEWROOT -p $NEWROOT/etc/selinux/targeted/contexts/files/file_contexts $NEWROOT

# ls -Z $NEWROOT >> /run/output.txt

# echo -n "-F " > $NEWROOT/.autorelabel
echo "PREPARE: DONE" >> /run/output.txt