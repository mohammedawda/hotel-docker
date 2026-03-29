# Base image
FROM php:8.2-fpm

# Arguments for environment
ARG user=www-data
ARG uid=1000

# Set working directory
WORKDIR /var/www

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libzip-dev \
    libonig-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libpq-dev \
    zip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring zip gd bcmath opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Add user (optional, match your host UID)
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /var/www && chown -R $user:$user /var/www

# Switch to non-root user
USER $user

# Copy existing Laravel code
# (we mount the folder via docker-compose, so this is optional)
# COPY ../backend /var/www

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]