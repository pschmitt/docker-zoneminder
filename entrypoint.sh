#!/usr/bin/env ash

# Edit config file
ZM_CONFIG=/etc/zm.conf
ZM_SERVER_HOST=${ZM_SERVER_HOST:-localhost}
ZM_DB_TYPE=${ZM_DB_TYPE:-mysql}
ZM_DB_HOST=${ZM_DB_HOST:-zm.db}
ZM_DB_PORT=${ZM_DB_PORT:-3306}
ZM_DB_NAME=${ZM_DB_NAME:-zoneminder}
ZM_DB_USER=${ZM_DB_USER:-zoneminder}
ZM_DB_PASS=${ZM_DB_PASS:-zoneminder}

sed -i "s/\(ZM_SERVER_HOST\)=.*/\1=$ZM_SERVER_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_TYPE\)=.*/\1=$ZM_DB_TYPE/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_HOST\)=.*/\1=$ZM_DB_HOST/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PORT\)=.*/\1=$ZM_DB_PORT/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_NAME\)=.*/\1=$ZM_DB_NAME/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_USER\)=.*/\1=$ZM_DB_USER/g" "$ZM_CONFIG"
sed -i "s/\(ZM_DB_PASS\)=.*/\1=$ZM_DB_PASS/g" "$ZM_CONFIG"

install -d -o lighttpd -g lighttpd /var/run/zoneminder
chown -R lighttpd:lighttpd "$ZM_CONFIG" /var/lib/zoneminder/* /var/run/zoneminder
chown -R lighttpd:wheel /var/log/zoneminder


# Wait for DB server to come up
# TODO
if ! mysqladmin --wait=30 -P "$ZM_DB_PORT" -u "$ZM_DB_USER" --password="$ZM_DB_PASS" -h "$ZM_DB_HOST" ping
then
    echo "Could not reach MySQL server in time... Abort." >&2
    exit 3
fi

# Init DB
DB_INITALIZED="$(mysql -u $ZM_DB_USER --password=$ZM_DB_PASS -h $ZM_DB_HOST $ZM_DB_NAME -e 'show tables;')"
if [[ -z "$DB_INITALIZED" ]]
then
    echo -n "Database has not been initialized... "
    sed -i 's/`zm`/'"$ZM_DB_NAME"'/g' /usr/share/zoneminder/db/zm_create.sql
    # /etc/init.d/zoneminder setup
    mysql -u "$ZM_DB_USER" -p"$ZM_DB_PASS" -h "$ZM_DB_HOST" -P "$ZM_DB_PORT" < "/usr/share/zoneminder/db/zm_create.sql"
    echo 'Done!'
fi

# Start server
exec supervisord
