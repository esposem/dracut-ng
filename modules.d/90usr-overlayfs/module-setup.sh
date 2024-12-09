#!/bin/bash

check() {
    # Return 255 to only include the module, if another module requires it.
    return 255
}

depends() {
    echo systemd-repart systemd-cryptsetup overlayfs
}

install() {
    inst_simple "$moddir/overlay-usr.service" "$systemdsystemunitdir/overlay-usr.service"
    inst_simple "$moddir/setup-overlay-usr.sh" "/usr/local/bin/setup-overlay-usr.sh"

    $SYSTEMCTL -q --root "$initdir" enable overlay-usr.service
}
