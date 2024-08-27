#!/bin/bash

check() {
    # Return 255 to only include the module, if another module requires it.
    return 255
}

depends() {
    echo systemd-repart systemd-cryptsetup overlayfs
}

install() {
    inst_hook pre-pivot 00 "$moddir/mount-overlayroot.sh"
    inst_multiple -o mkfs.btrfs mkfs.ext4 mkfs.xfs
    inst_multiple chcon
}
