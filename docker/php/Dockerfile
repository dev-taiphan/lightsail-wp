FROM php:8.3.19-fpm

RUN apt-get update && apt-get install -y \
    mariadb-client \
    zip \
    unzip \
  && docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo_mysql \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Create user
RUN groupadd -g 1000 deploy && \
    useradd -u 1000 -g deploy -m -s /bin/bash deploy

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Add custom PHP config
COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html/

USER deploy

CMD ["php-fpm"]