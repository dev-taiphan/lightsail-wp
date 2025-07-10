# Step 1: Build frontend assets using Node.js
FROM node:23 AS assets-build

ARG ENV=dev1
ARG ASSETS_URL

WORKDIR /var/www/html

# Copy the .env file 
COPY .env.deploy ./.env

# Copy package.json and package-lock.json to prepare for npm install
COPY ./web/app/themes/awesome/package*.json ./web/app/themes/awesome/

# Copy assets directory
COPY ./web/app/themes/awesome/assets ./web/app/themes/awesome/assets

# Copy the gulpfile.mjs for asset compilation
COPY ./web/app/themes/awesome/gulpfile.mjs ./web/app/themes/awesome/gulpfile.mjs 

# Install dependencies and compile production assets
RUN cd ./web/app/themes/awesome && npm install && \
    if [ "$ENV" = "prd" ]; then \
      npm run compile:assets:prd; \
    else \
      npm run compile:assets:dev; \
    fi

# Step 2: Build the main PHP image
FROM php:8.3.19-fpm

# Install necessary packages including MySQL client, nginx, and PHP extensions
RUN apt-get update && apt-get install -y \
    mariadb-client \
    zip unzip \
    nginx \
    gettext-base \
    curl \
    gnupg2 \
  && docker-php-ext-install -j$(nproc) mysqli pdo_mysql \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a deploy user with specific UID and GID
RUN groupadd -g 1000 deploy && \
    useradd -u 1000 -g deploy -m -s /bin/bash deploy

# Install Composer (PHP dependency manager) from the official composer image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install WP-CLI (WordPress CLI tool)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

# Copy the .env file again for the application
COPY .env.deploy ./.env

# Copy the entire application source code
COPY . .

# Ensure uploads directory exists and is writable
RUN mkdir -p /var/www/html/web/app/uploads \
  && chown -R www-data:www-data /var/www/html/web/app/uploads \
  && chmod -R 755 /var/www/html/web/app/uploads

# Overwrite the assets folder with the production build from the previous stage
COPY --from=assets-build /var/www/html/web/app/themes/awesome/assets /var/www/html/web/app/themes/awesome/assets

# Copy Nginx configuration template and use envsubst to insert FQDN
ARG FQDN=dev1.awe-some.best
COPY ./lightsail/conf/default.template /etc/nginx/conf.d/default.template
RUN envsubst '$FQDN' < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.conf

# Configure PHP-FPM to log to stdout/stderr
RUN sed -i 's|^error_log = .*|error_log = /proc/self/fd/2|' /usr/local/etc/php-fpm.conf && \
    echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf && \
    echo "php_admin_value[error_log] = /proc/self/fd/1" >> /usr/local/etc/php-fpm.d/www.conf
COPY ./lightsail/conf/fpm-docker.template /usr/local/etc/php-fpm.d/docker.conf

# Basic Authentication setup
ARG BASIC_AUTH_USER=user
ARG BASIC_AUTH_PASSWORD=pass
ARG ENV=dev1

RUN echo "Generating .htpasswd for $BASIC_AUTH_USER (env: $ENV)" && \
    printf '%s:%s\n' "$BASIC_AUTH_USER" "$BASIC_AUTH_PASSWORD" > /etc/nginx/.htpasswd && \
    if [ "$ENV" = "prd" ]; then \
      echo '' > /tmp/auth_block.txt && \
      echo 'auth_basic "Restricted";\nauth_basic_user_file /etc/nginx/.htpasswd;' > /tmp/admin_block.txt ; \
    else \
      echo 'auth_basic "Restricted";\nauth_basic_user_file /etc/nginx/.htpasswd;' > /tmp/auth_block.txt && \
      echo '' > /tmp/admin_block.txt ; \
    fi && \
    export AUTH_BLOCK="$(cat /tmp/auth_block.txt)" && \
    export ADMIN_BLOCK="$(cat /tmp/admin_block.txt)" && \
    envsubst '$FQDN' < /etc/nginx/conf.d/default.template > /etc/nginx/conf.d/default.raw && \
    awk -v block="$AUTH_BLOCK" -v admin="$ADMIN_BLOCK" '{gsub(/##AUTH_BLOCK##/, block); gsub(/##ADMIN_BLOCK##/, admin)}1' /etc/nginx/conf.d/default.raw > /etc/nginx/conf.d/default.conf

# Adjust nginx config to prevent server name hash errors
RUN sed -i '/http {/a \    server_names_hash_bucket_size 128;' /etc/nginx/nginx.conf

# Install PHP dependencies using Composer in production mode (no dev dependencies)
RUN composer install --no-dev --optimize-autoloader

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Start PHP-FPM and Nginx in the foreground
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
