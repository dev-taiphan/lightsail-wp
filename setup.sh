#!/bin/bash

# ─── Utility Functions ───────────────────────────────────────────
step() {
  echo -e "\033[33m[STEP $1] $2...\033[0m"
}
success() {
  echo -e "\033[38;5;213m[$1/5] $2: Done\033[0m\n"
}
fail() {
  echo -e "\033[31m✖ $1 failed. Aborting.\033[0m"
  exit 1
}

# ─── Load Environment File ───────────────────────────────────────
ENV_FILE=".env${1:+.$1}"

if [ ! -f "$ENV_FILE" ]; then
  echo -e "\033[31mError: Environment file '$ENV_FILE' not found!\033[0m"
  exit 1
fi

echo -e "\nLoading environment variables from $ENV_FILE...\n"
set -a  
source "$ENV_FILE"
set +a  

if [ -z "$APP_NAME" ] || [ "$APP_NAME" = "CHANGE_YOUR_APP_NAME" ]; then
  echo -e "\033[31mAPP_NAME is not set. Please check the $ENV_FILE file.\033[0m"
  exit 1
fi

# ─── Reusable Commands ───────────────────────────────────────────
PHP="docker compose exec -u 0 php"
NODE="docker compose exec -u 0 node"

# ─── Step 1: Docker Compose ──────────────────────────────────────
step 1 "Starting Docker Compose containers"
docker compose up -d --build || fail "Docker Compose"
success 1 "Create docker container"

# ─── Step 2: Composer Install ────────────────────────────────────
step 2 "Running Composer install"
$PHP composer install || fail "Composer install"
success 2 "Install composer package"

# ─── Step 3: Permissions ─────────────────────────────────────────
step 3 "Setting file ownership and permissions"
$PHP chown -R 1000:1000 web \
&& $PHP chmod 751 web \
&& $PHP chmod 0440 ./web/wp-config.php \
&& $PHP chmod 0775 ./web/app \
&& $PHP chmod -R 0775 ./web/app/uploads \
&& $PHP chmod -R 0775 ./web/app/plugins \
&& $PHP chmod -R 0775 ./web/app/languages \
&& $PHP chmod -R 0775 ./web/app/upgrade \
|| fail "File permissions"
success 3 "Set file ownership and permissions"

# ─── Step 4: NPM Install ─────────────────────────────────────────
step 4 "Installing npm packages"
$NODE npm install || fail "npm install"
success 4 "Install npm package"

# ─── Step 5: Compile Assets ──────────────────────────────────────
step 5 "Compiling theme assets"
docker compose exec -u 0 node npm run compile:assets:$WP_ENV || fail "Theme compilation"
success 5 "Compile theme assets"

# ─── Done ────────────────────────────────────────────────────────
echo -e "\033[32m[SETUP COMPLETED] HOME PAGE: $WP_HOME\033[0m"
