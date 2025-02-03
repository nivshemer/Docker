#!/bin/sh
set -e
if [ -d /etc/nginx/templates/ ]; then
	if [ "$VARIABLES_TO_EXPAND" != "" ]; then
		variables_to_expand=$VARIABLES_TO_EXPAND		
	else
		variables_to_expand='${AUTH_SERVER} ${AUTH_SERVER_API} ${AUTH_SERVER_ADMIN} ${NANOLOCK_API} ${NANOLOCK_CONFIG} ${NANOLOCK_CLIENTMONITORING} ${NANOLOCK_MNGTCLIENT} ${NANOLOCK_SERVERMONITORING}'
	fi
	envsubst "$variables_to_expand" < /etc/nginx/templates/nginx.conf > /etc/nginx/nginx.conf

	for filepath in /etc/nginx/templates/conf.d/*; do
		filename=$(basename "$filepath")
		envsubst "$variables_to_expand" < $filepath > /etc/nginx/conf.d/$filename
	done
else
	echo /etc/nginx/templates/ does not exist. Skipping variable expansion.
fi
if [ "$#" -eq 0 ]; then
	nginx -g "daemon off;"
else
	$@
fi

