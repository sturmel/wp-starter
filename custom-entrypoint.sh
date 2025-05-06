#!/bin/bash
set -e

WP_PATH=/var/www/html
WP_CONTENT_PATH=${WP_PATH}/wp-content
THEMES_PATH=${WP_CONTENT_PATH}/themes
PLUGINS_PATH=${WP_CONTENT_PATH}/plugins
TIMBER_THEME_DIR_NAME="timber"
TIMBER_REPO_URL="https://github.com/timber/timber.git"

if ! command -v mysqladmin &> /dev/null
then
    echo "mysqladmin could not be found. Installing mysql-client..."
    apt-get update && apt-get install -y default-mysql-client
    if ! command -v mysqladmin &> /dev/null
    then
        echo "Failed to install mysql-client. Please install it manually in the Docker image."
        exit 1
    fi
    echo "mysql-client installed."
fi

echo "Waiting for MySQL to be ready..."
until mysqladmin ping -h"db" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
    echo "MySQL is unavailable - sleeping"
    sleep 5
done
echo "MySQL is up - continuing..."

if ! command -v wp &> /dev/null
then
    echo "wp-cli could not be found. Attempting to install it..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    if [ -f wp-cli.phar ]; then
        chmod +x wp-cli.phar
        mv wp-cli.phar /usr/local/bin/wp
        if command -v wp &> /dev/null; then
            echo "wp-cli installed successfully."
        else
            echo "Failed to install wp-cli. Please install it manually in the Docker image."
            exit 1
        fi
    else
        echo "Failed to download wp-cli.phar. Please check network connectivity or install manually."
        exit 1
    fi
else
  echo "wp-cli is available."
fi

WP_CONFIG_FILE="${WP_PATH}/wp-config.php"

if [ ! -e "${WP_PATH}/index.php" ] || [ ! -e "${WP_PATH}/wp-includes/version.php" ]; then
    echo "[CustomScript] WordPress core files not found in ${WP_PATH}. Copying from /usr/src/wordpress..."
    if [ -d "/usr/src/wordpress" ]; then
        (cd /usr/src/wordpress && tar cf - . | tar xf - -C "$WP_PATH")
        echo "[CustomScript] WordPress core files copied."
    else
        echo "[CustomScript ERROR] /usr/src/wordpress not found. Cannot copy core files."
        exit 1
    fi
fi

if [ ! -e "$WP_CONFIG_FILE" ]; then
    echo "[CustomScript] $WP_CONFIG_FILE not found. Creating..."
    if [ -f "${WP_PATH}/wp-config-docker.php" ]; then
        echo "[CustomScript] Using ${WP_PATH}/wp-config-docker.php as template."
        cp "${WP_PATH}/wp-config-docker.php" "$WP_CONFIG_FILE"
    elif [ -f "/usr/src/wordpress/wp-config-docker.php" ]; then
        echo "[CustomScript] Using /usr/src/wordpress/wp-config-docker.php as template."
        cp "/usr/src/wordpress/wp-config-docker.php" "$WP_CONFIG_FILE"
    else
        echo "[CustomScript ERROR] wp-config-docker.php not found. Cannot create $WP_CONFIG_FILE."
        exit 1
    fi

    sed -i -e "s/database_name_here/${WORDPRESS_DB_NAME}/g" \
           -e "s/username_here/${WORDPRESS_DB_USER}/g" \
           -e "s/password_here/${WORDPRESS_DB_PASSWORD}/g" \
           -e "s/localhost/${WORDPRESS_DB_HOST}/g" \
           "$WP_CONFIG_FILE"

    if [ -n "${WORDPRESS_TABLE_PREFIX:-}" ]; then
        sed -i -e "s/\$table_prefix = 'wp_';/\$table_prefix = '$WORDPRESS_TABLE_PREFIX';/g" "$WP_CONFIG_FILE"
    fi
    echo "[CustomScript] $WP_CONFIG_FILE created. Salts will be configured after core install."
fi

if ! wp core is-installed --path="$WP_PATH" --allow-root --quiet; then
    echo "[CustomScript] WordPress core is not installed. Installing..."
    if [ -z "${WORDPRESS_URL:-}" ] || [ -z "${WORDPRESS_TITLE:-}" ] || \
       [ -z "${WORDPRESS_ADMIN_USER:-}" ] || [ -z "${WORDPRESS_ADMIN_PASSWORD:-}" ] || \
       [ -z "${WORDPRESS_ADMIN_EMAIL:-}" ]; then
        echo "[CustomScript ERROR] Missing required environment variables for 'wp core install': WORDPRESS_URL, WORDPRESS_TITLE, WORDPRESS_ADMIN_USER, WORDPRESS_ADMIN_PASSWORD, WORDPRESS_ADMIN_EMAIL."
        echo "[CustomScript] Cannot proceed. Please set them in docker-compose.yml and restart the container."
        exit 1
    fi

    wp core install --url="$WORDPRESS_URL" \
                    --title="$WORDPRESS_TITLE" \
                    --admin_user="$WORDPRESS_ADMIN_USER" \
                    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
                    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
                    --skip-email \
                    --path="$WP_PATH" --allow-root
    echo "[CustomScript] WordPress core installed."

    echo "[CustomScript] Configuring salts in $WP_CONFIG_FILE..."
    wp config shuffle-salts --path="$WP_PATH" --allow-root --quiet || echo "[CustomScript WARNING] Failed to shuffle salts. May need to be done manually if not already set."
else
    echo "[CustomScript] WordPress is already installed."
fi

echo "[CustomScript] Proceeding with Composer, Timber theme, and plugin installations..."

if ! command -v git &> /dev/null; then
    echo "[CustomScript] git not found. Installing git..."
    apt-get update && apt-get install -y git --no-install-recommends || echo "[CustomScript WARNING] Failed to install git."
fi
if ! command -v unzip &> /dev/null; then
    echo "[CustomScript] unzip not found. Installing unzip..."
    apt-get update && apt-get install -y unzip --no-install-recommends || echo "[CustomScript WARNING] Failed to install unzip."
fi

if ! command -v composer &> /dev/null; then
    echo "[CustomScript] Composer not found. Installing Composer..."
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
        >&2 echo '[CustomScript ERROR] Invalid composer installer checksum'
        rm composer-setup.php
        exit 1
    fi

    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
    composer --version
    echo "[CustomScript] Composer installed successfully to /usr/local/bin/composer."
else
    echo "[CustomScript] Composer is already installed."
fi

STARTER_THEME_SLUG="timber-starter-theme"
STARTER_THEME_PATH="${THEMES_PATH}/${STARTER_THEME_SLUG}"

if [ ! -d "${STARTER_THEME_PATH}" ]; then
    echo "[CustomScript] Timber Starter Theme not found at ${STARTER_THEME_PATH}. Installing..."
    mkdir -p "${THEMES_PATH}"
    if cd "${THEMES_PATH}"; then
        composer create-project upstatement/timber-starter-theme "${STARTER_THEME_SLUG}" --no-dev --prefer-dist
        echo "[CustomScript] Timber Starter Theme installed in ${STARTER_THEME_PATH}."

        echo "[CustomScript] Activating theme: ${STARTER_THEME_SLUG}"
        if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
            echo "[CustomScript] Theme ${STARTER_THEME_SLUG} activated successfully."
        else
            echo "[CustomScript WARNING] Failed to activate theme ${STARTER_THEME_SLUG}."
        fi
        cd "$OLDPWD"
    else
        echo "[CustomScript ERROR] Could not cd to ${THEMES_PATH}. Cannot install Timber Starter Theme."
    fi
else
    echo "[CustomScript] Timber Starter Theme already exists at ${STARTER_THEME_PATH}."
    CURRENT_THEME=$(wp theme get --status=active --field=stylesheet --path="${WP_PATH}" --allow-root --quiet)
    if [ "$CURRENT_THEME" != "$STARTER_THEME_SLUG" ]; then
        echo "[CustomScript] Activating existing theme: ${STARTER_THEME_SLUG}"
        if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
            echo "[CustomScript] Theme ${STARTER_THEME_SLUG} activated successfully."
        else
            echo "[CustomScript WARNING] Failed to activate existing theme ${STARTER_THEME_SLUG}."
        fi
    else
        echo "[CustomScript] Theme ${STARTER_THEME_SLUG} is already active."
    fi
fi

PLUGINS_TO_INSTALL=(
  "advanced-custom-fields"
  "wordpress-seo"
  "litespeed-cache"
  "contact-form-7"
)

for plugin_slug in "${PLUGINS_TO_INSTALL[@]}"; do
  echo "[CustomScript] Checking plugin: ${plugin_slug}"
  if ! is_plugin_active "${plugin_slug}"; then
    echo "[CustomScript] Attempting to install and activate ${plugin_slug}..."
    if wp plugin install "${plugin_slug}" --activate --path="${WP_PATH}" --allow-root; then
      echo "[CustomScript] ${plugin_slug} installed and activated successfully."
    else
      echo "[CustomScript WARNING] Failed to install/activate ${plugin_slug}. Check slug or WordPress readiness."
    fi
  else
    echo "[CustomScript] Plugin ${plugin_slug} already installed and active."
  fi
done

echo "[CustomScript] Custom theme and plugin installation tasks complete."

echo "[CustomScript] Script finished. Starting main process (exec \"$@\")..."
exec "$@"
