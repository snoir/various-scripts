#!/bin/sh
#
# Let's encrypt renew with lego and OVH as DNS provider
#

set -e

ovh_api_config_file="${API_CONFIG_FILE:-/opt/config/acme/ovh_api}"
required_config="email consumer_key application_key application_secret endpoint"
acme_path="/data/acme/"

. $ovh_api_config_file

for i in $required_config; do
	eval "c=\$$i"
	if [ -z ${c} ]; then
		echo "Missing '${i}' in configuration (${ovh_api_config_file})"
		exit 1
	fi
done

set -u

for domain in $(lego --path /data/acme/ list -n); do
	OVH_CONSUMER_KEY=$consumer_key \
	OVH_APPLICATION_KEY=$application_key \
	OVH_APPLICATION_SECRET=$application_secret \
	OVH_ENDPOINT=$endpoint \
	lego --pem --email="${email}" --domains="$domain" --dns ovh --pem \ 
		--path=/data/acme/ -a renew \ 
		--renew-hook=/opt/scripts/acme-renew-hook.sh
done
