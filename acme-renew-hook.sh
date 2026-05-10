#!/bin/sh
#
# Script to restart services after certificates renewal
#
set -eu

services="nginx haproxy postfix dovecot prosody"

if grep prosody_enable=\"YES\" /etc/rc.conf 2> /dev/null; then
        prosodyctl --root cert import noir.im /data/acme/certificates
fi

for i in $services; do
        if grep ${i}_enable=\"YES\" /etc/rc.conf 2> /dev/null; then
                service $i restart
        fi
done
