#!/bin/sh
set -e

# Pastikan APP_KEY sudah ter-set (hanya generate kalau belum ada)
if [ -z "$APP_KEY" ]; then
  if [ ! -f .env ] || ! grep -q '^APP_KEY=' .env || grep -q '^APP_KEY=$' .env; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
  fi
fi

# Run optimization commands
echo "Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

echo "Running migrations..."
php artisan migrate --force --no-interaction

echo "Caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "Creating storage link..."
php artisan storage:link

echo "Starting Apache..."
exec "$@"
