FROM arm32v7/alpine:latest

ENV \
    MW_VERSION=1.32 \
    MW_PATCH_VERSION=1 

ARG MW_EXTENSIONS

RUN \
    apk update \
    && apk add \
    curl \
    tar \
    bash \
    diffutils \
    git \
    jq \
    php7 \
    php7-bz2 \
    php7-phar \
    php7-zip \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-simplexml \
    php7-ctype \
    php7-iconv \
    php7-common \
    php7-tokenizer \
    php7-mysqli \
    php7-fpm \
    php7-gd \
    php7-dom \
    php7-json \
    php7-mbstring \
    php7-session \
    php7-fileinfo

RUN \
    # Install mediawiki
    mkdir -p /var/www \
    && curl -LsS https://releases.wikimedia.org/mediawiki/${MW_VERSION}/mediawiki-${MW_VERSION}.${MW_PATCH_VERSION}.tar.gz|tar xz -C /var/www \
    && mv /var/www/mediawiki* /var/www/mediawiki \
    && adduser -S -D -H www \
    && chown -R www /var/www/mediawiki \
    # Install composer
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');" \
    # Tweak configs
    && sed -i \
    -e "s,expose_php = On,expose_php = Off,g" \
    -e "s,;cgi.fix_pathinfo=1,cgi.fix_pathinfo=0,g" \
    -e "s,post_max_size = 8M,post_max_size = 100M,g" \
    -e "s,upload_max_filesize = 2M,upload_max_filesize = 100M,g" \
    /etc/php7/php.ini \
    && sed -i \
    -e "s,;daemonize = yes,daemonize = no,g" \
    -e "s,user = nobody,user = www,g" \
    -e "s,;chdir = /var/www,chdir = /var/www/mediawiki,g" \
    -e "s,;listen.owner = nobody,listen.owner = www,g" \
    -e "s,;listen.group = nobody,listen.group = www,g" \
    -e "s,listen = 127.0.0.1:9000,listen = 0.0.0.0:9000,g" \
    -e "s,;clear_env = no,clear_env = no,g" \
    /etc/php7/php-fpm.d/www.conf \
    # forward logs to docker log collector
    && ln -sf /dev/stderr /var/log/php7/error.log

USER www

WORKDIR /var/www/mediawiki

# Composer installable extensions
COPY conf/composer.local.json .

# extensions.json is json list of non-composer installable mediawiki extensions
COPY conf/extensions.json .
COPY scripts/install_extensions.sh .

# Install mw extensions
RUN /usr/local/bin/composer update --no-dev;
RUN ./install_extensions.sh && rm install_extensions.sh extensions.json

EXPOSE 9000

ENTRYPOINT ["php-fpm7", "-F"]
