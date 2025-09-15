# -------- Stage 1: install PHP deps with Composer --------
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress

# -------- Stage 2: runtime (Apache + PHP) --------
FROM php:8.2-apache

# Enable useful Apache/PHP settings
RUN a2enmod rewrite \
 && apt-get update \
 && apt-get install -y --no-install-recommends git unzip \
 && rm -rf /var/lib/apt/lists/*

# If you need extra PHP extensions later, add lines like:
# RUN docker-php-ext-install pdo pdo_mysql mbstring

WORKDIR /var/www/html

# Copy dependencies from the Composer stage
COPY --from=vendor /app/vendor /var/www/html/vendor

# Copy the rest of the application
COPY . /var/www/html

# Start script that adjusts Apache to Render's $PORT and starts it
COPY docker/start-apache.sh /usr/local/bin/start-apache.sh
RUN chmod +x /usr/local/bin/start-apache.sh

# Default port Render uses (actual port is provided via $PORT)
ENV PORT=8080

CMD ["start-apache.sh"]
