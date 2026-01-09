FROM php:8.3-apache

# Set server name untuk menghindari warning Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Install dependencies sistem dan ekstensi PHP
RUN apt-get update && apt-get install -y \
    unzip zip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    libjpeg-dev libfreetype6-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install gd zip pdo pdo_mysql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Aktifkan Apache mod_rewrite (untuk routing Laravel)
RUN a2enmod rewrite

# Set working directory Laravel
WORKDIR /var/www/html

# Salin semua file Laravel ke dalam container
COPY . .

# Pastikan bootstrap/cache & storage writable
RUN mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/www/html/storage \
    && chmod -R 777 /var/www/html/bootstrap/cache /var/www/html/storage

# Pastikan .env tersedia saat build (supaya artisan tidak error)
RUN cp .env.example .env || true

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Jalankan Composer install + semua script artisan otomatis
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Jalankan artisan command tambahan saat build
RUN php artisan key:generate \
    && php artisan config:clear \
    && php artisan route:clear \
    && php artisan view:clear \
    && php artisan cache:clear \
    && php artisan migrate --force || true


# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && npm install \
    && npm run build

# Expose port 80
EXPOSE 80
