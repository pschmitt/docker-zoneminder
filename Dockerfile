FROM alpine:3.4

MAINTAINER Philipp Schmitt <philipp@schmitt.co>

RUN apk add --no-cache zoneminder mysql-client lighttpd php5-fpm \
        php5-pdo php5-pdo_mysql supervisor ffmpeg

RUN sed -i 's/\(user\|group\) = .*/\1 = lighttpd/g' /etc/php5/php-fpm.conf \
    && sed -i 's/#.*\(include "mod_\(cgi\|fastcgi_fpm\).conf"\)/\1/g' \
        /etc/lighttpd/lighttpd.conf \
    && sed -i 's|\(server.document-root\) = .*|\1 = var.basedir + "/htdocs/zm"|g' \
        /etc/lighttpd/lighttpd.conf \
    && sed -i 's/\(ZM_WEB_\(USER\|GROUP\)\)=.*/\1=lighttpd/g' /etc/zm.conf

VOLUME /config

EXPOSE 80

ENV ZM_SERVER_HOST=localhost ZM_DB_TYPE=mysql ZM_DB_HOST=zm.db \
    ZM_DB_PORT=3306 ZM_DB_NAME=zoneminder ZM_DB_USER=zoneminder \
    ZM_DB_PASS=zoneminder

COPY entrypoint.sh /entrypoint.sh
COPY supervisord.conf /etc/supervisord.conf
COPY zm_mysql.sh /usr/bin/zm_mysql.sh

ENTRYPOINT ["/entrypoint.sh"]
