#!/bin/sh
set -e

# Pastikan APP_KEY sudah ter-set (hanya generate kalau belum ada)
if [ -z "$APP_KEY" ]; then
  # Pastikan file .env ada dulu agar key:generate tidak error
  if [ ! -f .env ]; then
    if [ -f .env.production.example ]; then
      cp .env.production.example .env
    elif [ -f .env.example ]; then
      cp .env.example .env
    fi
  fi

  if [ -f .env ] && ( ! grep -q '^APP_KEY=' .env || grep -q '^APP_KEY=$' .env ); then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
  fi
fi

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
