#!/bin/bash

echo "[SetupWordPressCore] Setting up WordPress core..."

# Copy WordPress core files if not present
if [ ! -e "${WP_PATH}/index.php" ] || [ ! -e "${WP_PATH}/wp-includes/version.php" ]; then
    echo "[SetupWordPressCore] WordPress core files not found in ${WP_PATH}. Copying from /usr/src/wordpress..."
    if [ -d "/usr/src/wordpress" ]; then
        (cd /usr/src/wordpress && tar cf - . | tar xf - -C "$WP_PATH")
        echo "[SetupWordPressCore] WordPress core files copied."
    else
        echo "[SetupWordPressCore ERROR] /usr/src/wordpress not found. Cannot copy core files."
        exit 1
    fi
fi

# Create wp-config.php if not present
if [ ! -e "$WP_CONFIG_FILE" ]; then
    echo "[SetupWordPressCore] $WP_CONFIG_FILE not found. Creating..."
    if [ -f "${WP_PATH}/wp-config-docker.php" ]; then
        echo "[SetupWordPressCore] Using ${WP_PATH}/wp-config-docker.php as template."
        cp "${WP_PATH}/wp-config-docker.php" "$WP_CONFIG_FILE"
    elif [ -f "/usr/src/wordpress/wp-config-docker.php" ]; then
        echo "[SetupWordPressCore] Using /usr/src/wordpress/wp-config-docker.php as template."
        cp "/usr/src/wordpress/wp-config-docker.php" "$WP_CONFIG_FILE"
    else
        echo "[SetupWordPressCore ERROR] wp-config-docker.php not found. Cannot create $WP_CONFIG_FILE."
        exit 1
    fi

    # Configure database settings
    sed -i -e "s/database_name_here/${WORDPRESS_DB_NAME}/g" \
        -e "s/username_here/${WORDPRESS_DB_USER}/g" \
        -e "s/password_here/${WORDPRESS_DB_PASSWORD}/g" \
        -e "s/localhost/${WORDPRESS_DB_HOST}/g" \
        "$WP_CONFIG_FILE"

    # Configure table prefix if set
    if [ -n "${WORDPRESS_TABLE_PREFIX:-}" ]; then
        sed -i -e "s/\\$table_prefix = \'wp_\';/\\$table_prefix = \'$WORDPRESS_TABLE_PREFIX\';/g" "$WP_CONFIG_FILE"
    fi
    echo "[SetupWordPressCore] $WP_CONFIG_FILE created. Salts will be configured after core install."
fi

# Install WordPress if not already installed
if ! wp core is-installed --path="$WP_PATH" --allow-root --quiet; then
    echo "[SetupWordPressCore] WordPress core is not installed. Installing..."
    if [ -z "${WORDPRESS_URL:-}" ] || [ -z "${WORDPRESS_TITLE:-}" ] || \
       [ -z "${WORDPRESS_ADMIN_USER:-}" ] || [ -z "${WORDPRESS_ADMIN_PASSWORD:-}" ] || \
       [ -z "${WORDPRESS_ADMIN_EMAIL:-}" ]; then
        echo "[SetupWordPressCore ERROR] Missing required environment variables for WordPress installation."
        exit 1
    fi

    wp core install --url="$WORDPRESS_URL" \
                    --title="$WORDPRESS_TITLE" \
                    --admin_user="$WORDPRESS_ADMIN_USER" \
                    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
                    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
                    --skip-email \
                    --path="$WP_PATH" --allow-root
    echo "[SetupWordPressCore] WordPress core installed."

    echo "[SetupWordPressCore] Configuring salts in $WP_CONFIG_FILE..."
    wp config shuffle-salts --path="$WP_PATH" --allow-root --quiet || echo "[SetupWordPressCore WARNING] Failed to shuffle salts. May need to be done manually if not already set."
else
    echo "[SetupWordPressCore] WordPress is already installed."
fi

echo "[SetupWordPressCore] WordPress core setup complete."
