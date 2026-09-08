#!/bin/sh
set -eu

mkdir -p storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs storage/app/public bootstrap/cache
composer install --no-interaction --prefer-dist
php artisan config:clear
php artisan migrate --force
exec php artisan serve --host=0.0.0.0 --port=8000 --no-reload
