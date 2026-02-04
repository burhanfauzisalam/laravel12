#!/bin/sh
set -e

# Run standard Laravel production commands

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
