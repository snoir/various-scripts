#!/bin/sh
#
# Script to restart services after certificates renewal
#
set -eu

services="nginx haproxy postfix dovecot prosody"

if sysrc prosody_enable 2> /dev/null | grep YES > /dev/null 2>&1; then
	prosodyctl --root cert import noir.im /data/acme/certificates
fi

for i in $services; do
        if sysrc ${i}_enable 2> /dev/null | grep YES > /dev/null 2>&1 ; then
                service $i restart
        fi
done
