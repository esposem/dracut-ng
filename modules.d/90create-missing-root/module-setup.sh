#!/bin/bash

check() {
    # Return 255 to only include the module, if another module requires it.
    return 255
}

depends() {
    echo systemd-repart systemd-cryptsetup overlayfs
}

install() {
    inst_simple "$moddir/build-root.service" "$systemdsystemunitdir/build-root.service"
    inst_simple "$moddir/build-root.sh" "/usr/bin/build-root.sh"
    $SYSTEMCTL -q --root "$initdir" enable build-root.service

    inst_simple "$moddir/prepare-root.service" "$systemdsystemunitdir/prepare-root.service"
    inst_simple "$moddir/prepare-root.sh" "/usr/bin/prepare-root.sh"
    $SYSTEMCTL -q --root "$initdir" enable prepare-root.service

    inst_simple "$moddir/finish-root.service" "$systemdsystemunitdir/finish-root.service"
    inst_simple "$moddir/finish-root.sh" "/usr/bin/finish-root.sh"
    $SYSTEMCTL -q --root "$initdir" enable finish-root.service

    if [ -f "/etc/create-missing-root.conf" ]; then
        inst_simple "/etc/create-missing-root.conf" "/etc/create-missing-root.conf"
    else
        inst_simple "${moddir}/default-root.conf" "/etc/create-missing-root.conf"
    fi

    inst_multiple -o mkfs.btrfs mkfs.ext4 mkfs.xfs lsblk jq chroot
}


