#!/bin/sh
set -e

# Asumsikan semua konfigurasi (termasuk APP_KEY) berasal dari environment
# yang diisi oleh docker-compose (env_file: .env di host). Di sini kita
# tidak lagi mengubah .env di dalam container, hanya menjalankan perintah
# Laravel standar untuk production.

echo "Running migrations..."
php artisan migrate --force --no-interaction

# Run optimization commands (setelah DB siap supaya cache database tidak error)
echo "Clearing caches..."
php artisan config:clear
php artisan cache:clear || true
php artisan route:clear
php artisan view:clear

echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Creating storage link..."
php artisan storage:link

echo "Starting Apache..."
exec "$@"
