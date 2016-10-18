#!/usr/bin/env ash

. /etc/zm.conf

mysql -h "$ZM_DB_HOST" -P "$ZM_DB_PORT" -u "$ZM_DB_USER" -p"$ZM_DB_PASS" "$ZM_DB_NAME" "$@"
