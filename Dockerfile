FROM node:22-alpine AS node_builder

WORKDIR /var/www/html

COPY package.json package-lock.json* vite.config.js ./
COPY resources ./resources

RUN npm install && npm run build

FROM php:8.2-fpm-alpine AS app

RUN apk add --no-cache \
    nginx \
    supervisor \
    bash \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    freetype-dev \
    oniguruma-dev \
    libxml2-dev \
    zip \
    unzip \
    icu-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install pdo_mysql mbstring bcmath exif pcntl gd intl

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY composer.json composer.lock ./

RUN composer install \
    --no-dev \
    --no-interaction \
    --prefer-dist \
    --optimize-autoloader \
    --no-scripts

COPY . .

COPY --from=node_builder /var/www/html/public/build ./public/build

RUN chown -R www-data:www-data storage bootstrap/cache && \
    mkdir -p /run/nginx

COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf
COPY docker/supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

