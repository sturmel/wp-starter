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
        sed -i -e "s/\\$table_prefix = \'wp_\';/\\$table_prefix = \'$WORDPRESS_TABLE_PREFIX\';/g" "$WP_CONFIG_FILE"
    fi
    echo "[CustomScript] $WP_CONFIG_FILE created. Salts will be configured after core install."
fi

if ! wp core is-installed --path="$WP_PATH" --allow-root --quiet; then
    echo "[CustomScript] WordPress core is not installed. Installing..."
    if [ -z "${WORDPRESS_URL:-}" ] || [ -z "${WORDPRESS_TITLE:-}" ] || \
       [ -z "${WORDPRESS_ADMIN_USER:-}" ] || [ -z "${WORDPRESS_ADMIN_PASSWORD:-}" ] || \
       [ -z "${WORDPRESS_ADMIN_EMAIL:-}" ]; then
        echo "[CustomScript ERROR] Missing required environment variables for WordPress installation."
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

echo "[CustomScript] Proceeding with Composer, Timber theme, and plugin installations... (Tools like git, unzip, msmtp, composer, node should be pre-installed from Dockerfile)"

MSMTP_CONFIG_FILE="/etc/msmtprc"
echo "[CustomScript] Configuring msmtp..."

MSMTP_CONTENT="defaults\\n"
MSMTP_CONTENT+="auth ${MSMTP_AUTH:-on}\\n"
MSMTP_CONTENT+="tls ${MSMTP_TLS:-off}\\n"
MSMTP_CONTENT+="tls_starttls ${MSMTP_TLS_STARTTLS:-on}\\n"
MSMTP_CONTENT+="tls_trust_file /etc/ssl/certs/ca-certificates.crt\\n"
if [ -n "${MSMTP_LOGFILE:-}" ]; then
    MSMTP_CONTENT+="logfile ${MSMTP_LOGFILE}\\n" 
else
    MSMTP_CONTENT+="logfile /dev/null\\n" 
fi
MSMTP_CONTENT+="\\naccount default\\n"
MSMTP_CONTENT+="host ${MSMTP_HOST}\\n"
MSMTP_CONTENT+="port ${MSMTP_PORT}\\n"
MSMTP_CONTENT+="from ${MSMTP_FROM}\\n"

if [ "${MSMTP_AUTH:-on}" = "on" ] && [ -n "${MSMTP_USER:-}" ]; then
    MSMTP_CONTENT+="user ${MSMTP_USER}\\n"
    MSMTP_CONTENT+="password ${MSMTP_PASSWORD}\\n"
fi

echo -e "${MSMTP_CONTENT}" > "${MSMTP_CONFIG_FILE}"
chmod 644 "${MSMTP_CONFIG_FILE}"
echo "[CustomScript] ${MSMTP_CONFIG_FILE} configured from environment variables."

CURRENT_ENV="${WORDPRESS_ENV:-development}"
echo "[CustomScript] Current environment: $CURRENT_ENV"

# Add Redis configuration
if [ -n "${WORDPRESS_REDIS_HOST:-}" ] && [ -n "${WORDPRESS_REDIS_PORT:-}" ]; then
    echo "[CustomScript] Configuring Redis object cache..."
    wp config set WP_REDIS_HOST "${WORDPRESS_REDIS_HOST}" --raw --path="$WP_PATH" --allow-root --quiet
    wp config set WP_REDIS_PORT "${WORDPRESS_REDIS_PORT}" --raw --path="$WP_PATH" --allow-root --quiet
    if [ -n "${WORDPRESS_REDIS_PASSWORD:-}" ]; then
        wp config set WP_REDIS_PASSWORD "${WORDPRESS_REDIS_PASSWORD}" --raw --path="$WP_PATH" --allow-root --quiet
    fi
    # Add other Redis settings if needed, e.g., database, prefix
    # wp config set WP_REDIS_DATABASE <db_number> --raw --path="$WP_PATH" --allow-root --quiet
    # wp config set WP_REDIS_PREFIX <prefix> --raw --path="$WP_PATH" --allow-root --quiet

    # Install and activate Redis Object Cache plugin if not already active
    if ! wp plugin is-installed redis-cache --path="$WP_PATH" --allow-root --quiet; then
        echo "[CustomScript] Installing Redis Object Cache plugin..."
        wp plugin install redis-cache --activate --path="$WP_PATH" --allow-root --quiet || echo "[CustomScript WARNING] Failed to install or activate Redis Object Cache plugin."
    elif ! wp plugin is-active redis-cache --path="$WP_PATH" --allow-root --quiet; then
        echo "[CustomScript] Activating Redis Object Cache plugin..."
        wp plugin activate redis-cache --path="$WP_PATH" --allow-root --quiet || echo "[CustomScript WARNING] Failed to activate Redis Object Cache plugin."
    else
        echo "[CustomScript] Redis Object Cache plugin already installed and active."
    fi
    
    # Enable Redis object cache
    wp redis enable --path="$WP_PATH" --allow-root --quiet || echo "[CustomScript WARNING] Failed to enable Redis object cache. May need to be done manually."
    echo "[CustomScript] Redis object cache configured and enabled."
fi


CUSTOM_THEME_SLUG="${CUSTOM_THEME_NAME:-custom-timber-theme}"
echo "[CustomScript] Custom theme name: $CUSTOM_THEME_SLUG"

STARTER_THEME_SLUG="timber-starter-theme"
STARTER_THEME_PATH="${THEMES_PATH}/${STARTER_THEME_SLUG}"
CUSTOM_THEME_PATH="${THEMES_PATH}/${CUSTOM_THEME_SLUG}"

ensure_composer_install() {
    local theme_path="$1"
    local theme_name="$2"
    if [ -d "${theme_path}" ]; then
        if [ ! -d "${theme_path}/vendor" ]; then
            echo "[CustomScript] Vendor directory not found in ${theme_name} at ${theme_path}. Running composer install..."
            if [ -f "${theme_path}/composer.json" ]; then
                if command -v composer &> /dev/null; then
                    (cd "${theme_path}" && composer install --no-dev --prefer-dist)
                    echo "[CustomScript] Composer install completed for ${theme_name}."
                else
                    echo "[CustomScript WARNING] Composer not found. Cannot run composer install for ${theme_name}."
                fi
            else
                echo "[CustomScript WARNING] composer.json not found in ${theme_name} at ${theme_path}. Cannot run composer install."
            fi
        else
            echo "[CustomScript] Vendor directory already exists in ${theme_name} at ${theme_path}."
        fi
    else
        echo "[CustomScript] Theme ${theme_name} not found at ${theme_path}. Skipping composer check."
    fi
}


ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}"

ensure_composer_install "${CUSTOM_THEME_PATH}" "${CUSTOM_THEME_SLUG}"

if [ "$CURRENT_ENV" = "development" ]; then
    echo "[CustomScript] In development mode, ensuring Timber starter theme is present and custom theme is installed and active."

    if [ ! -d "${STARTER_THEME_PATH}" ]; then
        echo "[CustomScript] Timber Starter Theme not found at ${STARTER_THEME_PATH}. Installing..."
        mkdir -p "${THEMES_PATH}"
        if cd "${THEMES_PATH}"; then

            composer create-project upstatement/timber-starter-theme "${STARTER_THEME_SLUG}" --no-dev --prefer-dist
            echo "[CustomScript] Timber Starter Theme installed in ${STARTER_THEME_PATH}."
            ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}" # Run composer install after creation
            cd "$OLDPWD"
        else
            echo "[CustomScript ERROR] Could not cd to ${THEMES_PATH}. Cannot install Timber Starter Theme."
        fi
    else
        echo "[CustomScript] Timber Starter Theme already exists at ${STARTER_THEME_PATH}."
        ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}" # Check on restart
    fi


    if [ ! -d "${CUSTOM_THEME_PATH}" ]; then
        echo "[CustomScript] Custom theme ${CUSTOM_THEME_SLUG} not found at ${CUSTOM_THEME_PATH}."
        if [ -d "${STARTER_THEME_PATH}" ]; then
            echo "[CustomScript] Copying ${STARTER_THEME_SLUG} to ${CUSTOM_THEME_SLUG}..."
            cp -r "${STARTER_THEME_PATH}" "${CUSTOM_THEME_PATH}"

            if [ -f "${CUSTOM_THEME_PATH}/style.css" ]; then
                sed -i "s/Theme Name: Timber Starter Theme/Theme Name: ${CUSTOM_THEME_SLUG}/g" "${CUSTOM_THEME_PATH}/style.css"

                sed -i "s/Text Domain: timber-starter-theme/Text Domain: ${CUSTOM_THEME_SLUG}/g" "${CUSTOM_THEME_PATH}/style.css"
                echo "[CustomScript] Updated style.css for ${CUSTOM_THEME_SLUG}."
            fi
            echo "[CustomScript] Custom theme ${CUSTOM_THEME_SLUG} created from ${STARTER_THEME_SLUG}."
            ensure_composer_install "${CUSTOM_THEME_PATH}" "${CUSTOM_THEME_SLUG}"
        else
            echo "[CustomScript ERROR] Cannot create custom theme as ${STARTER_THEME_SLUG} does not exist."
        fi
    else
        echo "[CustomScript] Custom theme ${CUSTOM_THEME_SLUG} already exists at ${CUSTOM_THEME_PATH}."
        ensure_composer_install "${CUSTOM_THEME_PATH}" "${CUSTOM_THEME_SLUG}" 
    fi


    if [ -d "${CUSTOM_THEME_PATH}" ]; then
        CUSTOM_THEME_STATUS=$(wp theme status "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root --field=status 2>/dev/null || echo "not-installed")
        if [ "$CUSTOM_THEME_STATUS" != "active" ]; then
            echo "[CustomScript] Activating theme: ${CUSTOM_THEME_SLUG}"
            if wp theme activate "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[CustomScript] Theme ${CUSTOM_THEME_SLUG} activated successfully."
            else
                echo "[CustomScript WARNING] Failed to activate theme ${CUSTOM_THEME_SLUG}."
            fi
        else
            echo "[CustomScript] Theme ${CUSTOM_THEME_SLUG} is already active."
        fi
    else
        echo "[CustomScript WARNING] Custom theme ${CUSTOM_THEME_SLUG} not found. Cannot activate."
    fi

else 
    echo "[CustomScript] In production mode. Ensuring custom theme is active if it exists, otherwise Timber starter, otherwise default."
    ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}"
    ensure_composer_install "${CUSTOM_THEME_PATH}" "${CUSTOM_THEME_SLUG}" 

    ACTIVE_THEME=$(wp theme list --status=active --field=name --path="${WP_PATH}" --allow-root 2>/dev/null || echo "")
    if [ -z "$ACTIVE_THEME" ] || [ "$ACTIVE_THEME" != "$CUSTOM_THEME_SLUG" ]; then
        echo "[CustomScript WARNING] Active theme is '$ACTIVE_THEME'. Attempting to activate ${CUSTOM_THEME_SLUG} if present."
        if [ -d "${CUSTOM_THEME_PATH}" ]; then
            if wp theme activate "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[CustomScript] Theme ${CUSTOM_THEME_SLUG} activated in production."
            else
                echo "[CustomScript ERROR] Failed to activate ${CUSTOM_THEME_SLUG} in production. Trying ${STARTER_THEME_SLUG}."
                if [ -d "${STARTER_THEME_PATH}" ]; then
                    if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                        echo "[CustomScript] Theme ${STARTER_THEME_SLUG} activated."
                    else
                        echo "[CustomScript ERROR] Failed to activate ${STARTER_THEME_SLUG}. Manual intervention may be required."
                    fi
                else
                    DEFAULT_THEME=$(wp theme list --field=name --path="${WP_PATH}" --allow-root | head -n 1)
                    if [ -n "$DEFAULT_THEME" ]; then
                         echo "[CustomScript WARNING] ${STARTER_THEME_SLUG} not found. Attempting to activate default theme: $DEFAULT_THEME"
                         if wp theme activate "$DEFAULT_THEME" --path="${WP_PATH}" --allow-root; then
                            echo "[CustomScript] Default theme $DEFAULT_THEME activated."
                         else
                            echo "[CustomScript ERROR] Failed to activate default theme $DEFAULT_THEME in production. Manual intervention required."
                         fi
                    else
                        echo "[CustomScript ERROR] No themes found to activate in production. WordPress may not function correctly."
                    fi
                fi
            fi
        elif [ -d "${STARTER_THEME_PATH}" ]; then
             echo "[CustomScript WARNING] Custom theme ${CUSTOM_THEME_SLUG} not found. Attempting to activate ${STARTER_THEME_SLUG}."
            if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[CustomScript] Theme ${STARTER_THEME_SLUG} activated."
            else
                echo "[CustomScript ERROR] Failed to activate ${STARTER_THEME_SLUG}. Manual intervention may be required."
            fi
        else
            DEFAULT_THEME=$(wp theme list --field=name --path="${WP_PATH}" --allow-root | head -n 1)
            if [ -n "$DEFAULT_THEME" ]; then
                 echo "[CustomScript WARNING] Neither custom nor starter theme found. Attempting to activate default theme: $DEFAULT_THEME"
                 if wp theme activate "$DEFAULT_THEME" --path="${WP_PATH}" --allow-root; then
                    echo "[CustomScript] Default theme $DEFAULT_THEME activated."
                 else
                    echo "[CustomScript ERROR] Failed to activate default theme $DEFAULT_THEME in production. Manual intervention required."
                 fi
            else
                echo "[CustomScript ERROR] No themes found to activate in production. WordPress may not function correctly."
            fi
        fi
    else
        echo "[CustomScript] Active theme in production: $ACTIVE_THEME."
    fi
fi


PLUGINS_TO_INSTALL=(
  "advanced-custom-fields"
  "wordpress-seo"
  "litespeed-cache"
  "contact-form-7"
)

if [ "$CURRENT_ENV" = "development" ]; then
    echo "[CustomScript] In development mode, ensuring plugins are installed and active."
    for plugin_slug in "${PLUGINS_TO_INSTALL[@]}"; do
      if ! wp plugin is-installed "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
        echo "[CustomScript] Installing plugin $plugin_slug..."
        wp plugin install "$plugin_slug" --activate --path="$WP_PATH" --allow-root || echo "[CustomScript WARNING] Failed to install/activate plugin $plugin_slug."
      elif ! wp plugin is-active "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
        echo "[CustomScript] Activating plugin $plugin_slug..."
        wp plugin activate "$plugin_slug" --path="$WP_PATH" --allow-root || echo "[CustomScript WARNING] Failed to activate plugin $plugin_slug."
      else
        echo "[CustomScript] Plugin $plugin_slug is already installed and active."
      fi
    done
else 
    echo "[CustomScript] In production mode, ensuring plugins are active if already installed."
    for plugin_slug in "${PLUGINS_TO_INSTALL[@]}"; do
        if wp plugin is-installed "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
            if ! wp plugin is-active "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
                echo "[CustomScript] Activating plugin $plugin_slug in production..."
                wp plugin activate "$plugin_slug" --path="$WP_PATH" --allow-root || echo "[CustomScript WARNING] Failed to activate plugin $plugin_slug in production."
            else
                echo "[CustomScript] Plugin $plugin_slug is already active in production."
            fi
        else
            echo "[CustomScript] Plugin $plugin_slug not installed in production. Skipping activation."
        fi
    done
fi


ALL_CONFIG_ADDITIONS="" # Initialize with empty string

# Check if WP_CACHE is already defined to avoid duplication
if ! grep -q "define( *'WP_CACHE' *, *true *);" "$WP_CONFIG_FILE"; then
    ALL_CONFIG_ADDITIONS="define( 'WP_CACHE', true );"
fi

if [ "$CURRENT_ENV" = "production" ]; then
    ALL_CONFIG_ADDITIONS="${ALL_CONFIG_ADDITIONS}\\ndefine( 'AUTOMATIC_UPDATER_DISABLED', true );\\ndefine( 'DISALLOW_FILE_MODS', true );"
else

    echo "[CustomScript] Development/other environment: Adding relevant constants to wp-config.php"
    ALL_CONFIG_ADDITIONS="${ALL_CONFIG_ADDITIONS}\\ndefine( 'AUTOMATIC_UPDATER_DISABLED', false );\\ndefine( 'DISALLOW_FILE_MODS', false );"
fi


if [ -f "$WP_CONFIG_FILE" ]; then
    echo "[CustomScript] Configuring WP_CACHE and environment constants in $WP_CONFIG_FILE..."

    sed -i "/WP_CACHE/d" "$WP_CONFIG_FILE"
    sed -i "/AUTOMATIC_UPDATER_DISABLED/d" "$WP_CONFIG_FILE"
    sed -i "/DISALLOW_FILE_MODS/d" "$WP_CONFIG_FILE"

    if sed "/\\/\\* That's all, stop editing! Happy publishing. \\*\\//i ${ALL_CONFIG_ADDITIONS}" "$WP_CONFIG_FILE" > "${WP_CONFIG_FILE}.tmp" && mv "${WP_CONFIG_FILE}.tmp" "$WP_CONFIG_FILE"; then
        echo "[CustomScript] WP_CACHE and environment constants configured in $WP_CONFIG_FILE."
    else
        echo "[CustomScript ERROR] Failed to write constants to $WP_CONFIG_FILE. A backup might be at ${WP_CONFIG_FILE}.tmp or manual check needed."
    fi
else
    echo "[CustomScript ERROR] $WP_CONFIG_FILE not found. Cannot set WP_CACHE or environment constants."
fi


echo "[CustomScript] Custom theme and plugin installation tasks complete."

echo "[CustomScript] Script finished. Starting main process (exec \"$@\")..."
exec "$@"