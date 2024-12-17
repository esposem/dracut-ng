#!/bin/bash

check() {
    # Return 255 to only include the module, if another module requires it.
    return 255
}

depends() {
    echo systemd-repart systemd-cryptsetup overlayfs
}

install() {
    # inst_hook pre-mount 99 "$moddir/build-root.sh"

    inst_simple "$moddir/build-root.service" "$systemdsystemunitdir/build-root.service"
    inst_simple "$moddir/build-root.sh" "/usr/local/bin/build-root.sh"
    $SYSTEMCTL -q --root "$initdir" enable build-root.service


    inst_simple "$moddir/populate-root.service" "$systemdsystemunitdir/populate-root.service"
    inst_simple "$moddir/populate-root.sh" "/usr/local/bin/populate-root.sh"
    $SYSTEMCTL -q --root "$initdir" enable populate-root.service


    inst_simple "$moddir/overlay-usr.service" "$systemdsystemunitdir/overlay-usr.service"
    inst_simple "$moddir/overlay-usr.sh" "/usr/local/bin/overlay-usr.sh"
    $SYSTEMCTL -q --root "$initdir" enable overlay-usr.service

    inst_multiple -o mkfs.btrfs mkfs.ext4 mkfs.xfs lsblk jq restorecon
}


