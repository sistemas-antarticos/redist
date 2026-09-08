FROM php:8.5-cli

RUN apt-get update \
    && apt-get install -y --no-install-recommends git unzip libpq-dev libsqlite3-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo_pgsql pdo_sqlite mbstring pcntl \
    && rm -rf /var/lib/apt/lists/*

RUN { \
        echo 'upload_max_filesize=500M'; \
        echo 'post_max_size=520M'; \
        echo 'memory_limit=512M'; \
    } > /usr/local/etc/php/conf.d/uploads.ini

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /app
ENV COMPOSER_ALLOW_SUPERUSER=1
