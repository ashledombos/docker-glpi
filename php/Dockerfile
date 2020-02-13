# new build stage
FROM php:7-fpm-alpine

# Install gd
RUN apk --update --no-cache add \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd

# Install mysql (sqlite is already installed)
RUN apk --update --no-cache add \
    mariadb-client \
  && docker-php-ext-install mysqli

# Install ldap
RUN apk --update --no-cache add \
  openldap-dev \
  && docker-php-ext-install ldap

# Install imap
RUN apk --update --no-cache add \
    imap-dev \
  && docker-php-ext-install imap

# Install xmlrpc and domxml
RUN apk --update --no-cache add \
    libxml2-dev \
  && docker-php-ext-install xmlrpc dom

# Install apcu
RUN apk --update --no-cache add \
  ${PHPIZE_DEPS} \
  && yes ""|pecl install apcu \
  && docker-php-ext-enable apcu \
  && apk del ${PHPIZE_DEPS}

# Install modules not needing any config
RUN docker-php-ext-install opcache exif

# Install curl (curl already installed)

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=0'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

VOLUME ["/code/"]

ENV GLPI_PACKAGE 9.4.5

# Install GLPI
RUN set -ex; \
  curl -o glpi.tgz -fSL "https://github.com/glpi-project/glpi/releases/download/${GLPI_PACKAGE}/glpi-${GLPI_PACKAGE}.tgz"; \
  tar xvfz glpi.tgz -C /usr/src/; \
  rm glpi.tgz; \
chown -R www-data:www-data /usr/src/glpi

# PHP
ENV PHP_MAX_EXECUTION_TIME 600
ENV PHP_MEMORY_LIMIT 256M
ENV PHP_POST_MAX_SIZE 40M
ENV PHP_UPLOAD_MAX_FILESIZE 32M
ENV PHP_TIMEZONE Europe/Paris

EXPOSE 9000

COPY ./5 /

COPY ./docker-entrypoint.sh /

ENTRYPOINT ["sh","/docker-entrypoint.sh"]

CMD ["php-fpm"]

