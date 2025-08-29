# Dockerfile for TS-JioTV on Render (php:8.2-apache)
FROM php:8.2-apache

# Arguments (you can change timezone if you want)
ARG TIMEZONE=Asia/Kolkata

# Install system dependencies, PHP extensions and utilities
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    wget \
    nano \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install -j$(nproc) pdo pdo_mysql mysqli gd zip mbstring curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install composer (optional)
RUN php -r "copy('https://getcomposer.org/installer','/tmp/composer-setup.php');" \
    && php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('/tmp/composer-setup.php');"

# Enable apache modules
RUN a2enmod rewrite headers

# Allow .htaccess overrides (so RewriteCond in .htaccess works)
RUN sed -ri "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

# Set ServerName to suppress warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Add HLS MIME types and CORS (global)
RUN { \
    echo ""; \
    echo "# HLS MIME types"; \
    echo "AddType application/vnd.apple.mpegurl .m3u8"; \
    echo "AddType video/mp2t .ts"; \
    echo ""; \
    echo "# CORS allow (if you need it)"; \
    echo "<IfModule mod_headers.c>"; \
    echo "  Header always set Access-Control-Allow-Origin \"*\""; \
    echo "  Header always set Access-Control-Allow-Methods \"GET,OPTIONS\""; \
    echo "  Header always set Access-Control-Allow-Headers \"Range,Content-Type\""; \
    echo "  Header always set Access-Control-Expose-Headers \"Content-Length,Content-Range\""; \
    echo "</IfModule>"; \
} >> /etc/apache2/apache2.conf

# Set working directory
WORKDIR /var/www/html

# Copy project files
COPY . /var/www/html/

# Ensure the assets/data folder is writable (where creds.jtv is stored)
RUN mkdir -p /var/www/html/assets/data \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/assets/data

# Optional: run composer install if you use composer.json
# Uncomment the following lines if you want composer to run during build
# RUN if [ -f composer.json ]; then composer install --no-dev --optimize-autoloader; fi

EXPOSE 80

# Use the default php:apache entrypoint
CMD ["apache2-foreground"]
