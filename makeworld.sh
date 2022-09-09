#!/bin/sh
#
# Very simple script to update FreeBSD by source
#

set -eu

cd /usr/src
if [ ! -f reboot.checkpoint ]; then
        echo "Phase 1: pull source code, build world / kernel and install kernel"
        git pull
        make -j4 buildworld
        make -j4 kernel
        touch reboot.checkpoint
        shutdown -r now
else
        echo "Phase 2: install world and run etcupdate "
        etcupdate -p
        make installworld
        etcupdate -B
        rm reboot.checkpoint
        shutdown -r now
fi
