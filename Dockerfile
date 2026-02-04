FROM php:8.3-apache AS base

# System dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    git unzip zip curl \
    libzip-dev \
    libpng-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev \
    libonig-dev libxml2-dev \
    libicu-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
 && docker-php-ext-install pdo pdo_mysql mysqli zip gd mbstring intl \
 && rm -rf /var/lib/apt/lists/*

# Apache & PHP configuration from ./docker
COPY docker/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY docker/php/php.ini /usr/local/etc/php/conf.d/php.ini
COPY docker/php/opcache.ini /usr/local/etc/php/conf.d/opcache.ini

RUN a2enmod rewrite \
 && echo "ServerName localhost" >> /etc/apache2/apache2.conf

WORKDIR /var/www/html
EXPOSE 80

# Frontend assets build stage (Vite)
FROM node:22-bookworm AS assets
WORKDIR /app
COPY . .
RUN npm install \
 && npm run build

# Composer dependencies build stage
FROM composer:2 AS composer_build
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-scripts --ignore-platform-req=php

# Final application image
FROM base AS app

ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/html

# Copy application code
COPY . .

# Copy built frontend assets from Node build stage
COPY --from=assets /app/public/build ./public/build

# Copy vendor from Composer build stage
COPY --from=composer_build /app/vendor ./vendor

# Siapkan .env dan APP_KEY saat build image
RUN if [ -f .env.production.example ]; then cp .env.production.example .env; elif [ -f .env.example ]; then cp .env.example .env; fi \
 && php artisan key:generate --force

# Laravel storage/cache directories & permissions
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs \
 && chown -R www-data:www-data storage bootstrap/cache \
 && find storage bootstrap/cache -type d -exec chmod 775 {} \; \
 && find storage bootstrap/cache -type f -exec chmod 664 {} \;

# Entrypoint: jalankan skrip Laravel + start Apache
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]
