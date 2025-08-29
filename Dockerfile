# Use official PHP + Apache image
FROM php:8.2-apache

# Install required system packages and PHP extensions (add more if needed)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libzip-dev \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_mysql mysqli gd zip

# Enable Apache modules
RUN a2enmod rewrite
RUN a2enmod headers

# Allow .htaccess overrides (so RewriteCond etc. works)
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Fix "ServerName not set" warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copy project files into container
COPY . /var/www/html/

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Expose port 80
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
