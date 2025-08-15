ARG ALPINE_VERSION=3.19.8
FROM alpine:${ALPINE_VERSION}
LABEL Maintainer="Ngoc Linh Pham <pnlinh1207@gmail.com>"
LABEL Description="Lightweight container with Nginx 1.20 & PHP 8.2 based on Alpine Linux."

# Setup document root
WORKDIR /var/www/html

# Install packages and remove default server definition
RUN apk add --no-cache \
  php82  \
  php82-fpm  \
  php82-bcmath  \
  php82-ctype  \
  php82-fileinfo \
  php82-json  \
  php82-mbstring  \
  php82-openssl  \
  php82-pdo_pgsql  \
  php82-curl  \
  php82-pdo  \
  php82-tokenizer  \
  php82-xml \
  php82-phar \
  php82-dom \
  php82-gd \
  php82-iconv \
  php82-xmlwriter \
  php82-xmlreader \
  php82-zip \
  php82-simplexml \
  php82-redis \
  php82-pdo_mysql \
  php82-pdo_sqlite \
  php82-soap \
  php82-pecl-apcu \
  php82-common \
  php82-sqlite3 \
  php82-session \
  curl \
  nginx \
  runit

# Install XDebug

# Create symlink so programs depending on `php` still function
RUN cp /usr/bin/php82 /usr/bin/php

# Install Composer
COPY --from=composer/composer:2-bin /composer /usr/bin/composer

# Configure nginx
COPY config/82/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/82/fpm-pool.conf /etc/php82/php-fpm.d/www.conf
COPY config/82/php.ini /etc/php82/conf.d/custom.ini

# Configure runit boot script
COPY config/82/boot.sh /sbin/boot.sh

# Make sure files/folders needed by the processes are accessable when they run under the www user
ARG nginxUID=1000
ARG nginxGID=1000

RUN adduser -D -u ${nginxUID} -g ${nginxGID} -s /bin/sh www && \
    mkdir -p /var/www/html && \
    mkdir -p /var/www/html/tmp && \
    mkdir -p /var/cache/nginx && \
    chown -R www:www /var/www/html && \
    chown -R www:www /run && \
    chown -R www:www /var/lib/nginx && \
    chown -R www:www /var/log/nginx

COPY config/82/nginx.run /etc/service/nginx/run
COPY config/82/php.run /etc/service/php/run

RUN chmod +x /etc/service/nginx/run \
    && chmod +x /etc/service/php/run

# Add application
COPY --chown=www src/ /var/www/html

# Expose the port nginx is reachable on
EXPOSE 80

# Let boot start nginx & php-fpm
CMD ["sh", "/sbin/boot.sh"]

# Configure a healthcheck to validate that everything is up & running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:80/fpm-ping
