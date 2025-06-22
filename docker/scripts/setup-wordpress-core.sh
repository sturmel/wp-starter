#!/bin/bash

echo "[WordPress Core] Setting up WordPress core configuration..."

# Remove object-cache.php if it exists to avoid conflicts on restart
if [ -f /var/www/html/wp-content/object-cache.php ]; then
    echo "[WordPress Core] Removing existing object-cache.php..."
    rm -f /var/www/html/wp-content/object-cache.php
    echo "[WordPress Core] object-cache.php removed successfully"
fi

# Extract host and port from WORDPRESS_DB_HOST
DB_HOST=$(echo $WORDPRESS_DB_HOST | cut -d: -f1)
DB_PORT=$(echo $WORDPRESS_DB_HOST | cut -d: -s -f2)
DB_PORT=${DB_PORT:-3306}

# Wait for database to be ready using netcat
echo "[WordPress Core] Waiting for database to be ready at $DB_HOST:$DB_PORT..."
until nc -z "$DB_HOST" "$DB_PORT"; do
    echo "[WordPress Core] Database not ready, waiting 3 seconds..."
    sleep 3
done

echo "[WordPress Core] Database is ready!"

# Wait a bit more to ensure MySQL is fully ready
sleep 2

# Check if WordPress is downloaded, if not download it
if [ ! -f /var/www/html/wp-config-sample.php ]; then
    echo "[WordPress Core] WordPress not found, downloading..."
    wp core download --allow-root --force
    echo "[WordPress Core] WordPress downloaded successfully"
fi

# Generate wp-config.php if it doesn't exist
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "[WordPress Core] Generating wp-config.php..."
    wp config create \
        --dbname=$WORDPRESS_DB_NAME \
        --dbuser=$WORDPRESS_DB_USER \
        --dbpass=$WORDPRESS_DB_PASSWORD \
        --dbhost=$WORDPRESS_DB_HOST \
        --dbprefix=$WORDPRESS_TABLE_PREFIX \
        --allow-root
    
    echo "[WordPress Core] Adding custom configuration for reverse proxy..."
    
    # Create the SSL configuration based on URL
    if [[ "$WORDPRESS_URL" == https://* ]]; then
        echo "[WordPress Core] HTTPS detected, enabling SSL enforcement..."
        SSL_CONFIG="
// Force SSL for admin and login areas for security
define('FORCE_SSL_ADMIN', true);
define('FORCE_SSL_LOGIN', true);"
    else
        echo "[WordPress Core] HTTP detected, SSL enforcement disabled"
        SSL_CONFIG="
// SSL enforcement disabled for HTTP URLs
// define('FORCE_SSL_ADMIN', true);
// define('FORCE_SSL_LOGIN', true);"
    fi
    
    # Insert the custom configuration after DB_COLLATE using a more robust method
    # First, create a backup of the current line after DB_COLLATE
    CUSTOM_CONFIG="

/**
 * CUSTOM WORDPRESS CONFIGURATION FOR REVERSE PROXY SSL
 * These lines ensure WordPress correctly detects HTTPS when behind a proxy.
 * They MUST be placed BEFORE the unique keys and salts.
 */

// Define WordPress URL and Site URL for proper asset loading and redirects
define('WP_HOME', '$WORDPRESS_URL');
define('WP_SITEURL', '$WORDPRESS_URL');
$SSL_CONFIG

// Detect HTTPS when behind a reverse proxy like Nginx
// This makes WordPress aware that the connection is secure,
// even if the internal connection to the Docker container is HTTP.
if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}
// Optionally, uncomment the next block if your proxy also sends X-Forwarded-SSL
// if (isset(\$_SERVER['HTTP_X_FORWARDED_SSL']) && \$_SERVER['HTTP_X_FORWARDED_SSL'] === 'on') {
//     \$_SERVER['HTTPS'] = 'on';
// }
"
    
    # Use awk to insert after the DB_COLLATE line
    awk -v config="$CUSTOM_CONFIG" '
    /define\( '\''DB_COLLATE'\''/ { print; print config; next }
    { print }
    ' /var/www/html/wp-config.php > /tmp/wp-config-new.php
    
    # Replace the original file
    mv /tmp/wp-config-new.php /var/www/html/wp-config.php
    
    echo "[WordPress Core] Custom reverse proxy configuration added to wp-config.php"
fi

# Now verify WordPress database connectivity
echo "[WordPress Core] Verifying WordPress database connectivity..."
if ! wp db check --allow-root 2>/dev/null; then
    echo "[WordPress Core] WordPress database check failed, retrying in 5 seconds..."
    sleep 5
    if ! wp db check --allow-root 2>/dev/null; then
        echo "[WordPress Core] ERROR: WordPress database connectivity failed"
        echo "[WordPress Core] Attempting to create database if it doesn't exist..."
        wp db create --allow-root 2>/dev/null || echo "[WordPress Core] Database creation failed or database already exists"
        sleep 2
        if ! wp db check --allow-root 2>/dev/null; then
            echo "[WordPress Core] FINAL ERROR: Cannot establish database connection"
            exit 1
        fi
    fi
fi

# Helper function to convert string to boolean
convert_to_boolean() {
    local value="$1"
    case "${value,,}" in
        true|1|yes|on) echo "true" ;;
        false|0|no|off|"") echo "false" ;;
        *) echo "false" ;;
    esac
}

# Helper function to set wp config with proper boolean handling
set_wp_config_boolean() {
    local key="$1"
    local value="$2"
    local default="$3"
    
    # Use provided value, or fall back to default
    local final_value="${value:-$default}"
    local boolean_value=$(convert_to_boolean "$final_value")
    
    if ! wp config has "$key" --allow-root 2>/dev/null; then
        wp config set "$key" "$boolean_value" --raw --allow-root
    else
        wp config set "$key" "$boolean_value" --raw --allow-root
    fi
    
    echo "[WordPress Core] Set $key to $boolean_value"
}

# Configure debug and environment settings
if [ "$WORDPRESS_ENV" = "development" ]; then
    echo "[WordPress Core] Configuring settings for development environment..."
    
    # Force direct file system method to avoid FTP prompts
    if ! wp config has FS_METHOD --allow-root 2>/dev/null; then
        wp config set FS_METHOD direct --allow-root
    else
        wp config set FS_METHOD direct --allow-root
    fi
    
    # Set debug settings - use env variables or development defaults
    set_wp_config_boolean "WP_DEBUG" "$WORDPRESS_DEBUG" "true"
    set_wp_config_boolean "WP_DEBUG_LOG" "$WORDPRESS_DEBUG_LOG" "true"
    set_wp_config_boolean "SCRIPT_DEBUG" "$WORDPRESS_SCRIPT_DEBUG" "true"
    set_wp_config_boolean "SAVEQUERIES" "$WORDPRESS_SAVEQUERIES" "true"
    
    # Handle WP_DEBUG_DISPLAY with WORDPRESS_SHOW_WARNINGS logic
    if [ -n "$WORDPRESS_DEBUG_DISPLAY" ]; then
        # If explicitly set in env, use that value
        set_wp_config_boolean "WP_DEBUG_DISPLAY" "$WORDPRESS_DEBUG_DISPLAY" "false"
    else
        # Fall back to WORDPRESS_SHOW_WARNINGS for backward compatibility
        set_wp_config_boolean "WP_DEBUG_DISPLAY" "$WORDPRESS_SHOW_WARNINGS" "false"
    fi
    
    # Remove WP_CACHE if it exists to avoid conflicts in development
    if wp config has WP_CACHE --allow-root 2>/dev/null; then
        wp config delete WP_CACHE --allow-root 2>/dev/null || true
    fi
    
    # Create debug directory if it doesn't exist
    mkdir -p /var/www/html/wp-content/debug
    chmod 755 /var/www/html/wp-content/debug
    
    echo "[WordPress Core] Development environment configured with debug settings"
    
elif [ "$WORDPRESS_ENV" = "production" ]; then
    echo "[WordPress Core] Configuring settings for production environment..."
    
    # Set debug settings - use env variables or production defaults
    set_wp_config_boolean "WP_DEBUG" "$WORDPRESS_DEBUG" "false"
    set_wp_config_boolean "WP_DEBUG_LOG" "$WORDPRESS_DEBUG_LOG" "false"
    set_wp_config_boolean "SCRIPT_DEBUG" "$WORDPRESS_SCRIPT_DEBUG" "false"
    set_wp_config_boolean "SAVEQUERIES" "$WORDPRESS_SAVEQUERIES" "false"
    
    # Handle WP_DEBUG_DISPLAY - in production, be more careful
    if [ -n "$WORDPRESS_DEBUG_DISPLAY" ]; then
        # If explicitly set in env, use that value
        set_wp_config_boolean "WP_DEBUG_DISPLAY" "$WORDPRESS_DEBUG_DISPLAY" "false"
    elif [ "${WORDPRESS_SHOW_WARNINGS:-false}" = "true" ]; then
        # If WORDPRESS_SHOW_WARNINGS is true, allow debug display for critical debugging
        set_wp_config_boolean "WP_DEBUG_DISPLAY" "true" "false"
        echo "[WordPress Core] Debug display enabled for production debugging"
    else
        # Default: no debug display in production
        set_wp_config_boolean "WP_DEBUG_DISPLAY" "false" "false"
    fi
    
    # Enable WP_CACHE for production
    if ! wp config has WP_CACHE --allow-root 2>/dev/null; then
        wp config set WP_CACHE true --raw --allow-root
    else
        wp config set WP_CACHE true --raw --allow-root
    fi
    
    # Disable file modifications
    if ! wp config has DISALLOW_FILE_EDIT --allow-root 2>/dev/null; then
        wp config set DISALLOW_FILE_EDIT true --raw --allow-root
    else
        wp config set DISALLOW_FILE_EDIT true --raw --allow-root
    fi
    
    if ! wp config has AUTOMATIC_UPDATER_DISABLED --allow-root 2>/dev/null; then
        wp config set AUTOMATIC_UPDATER_DISABLED true --raw --allow-root
    else
        wp config set AUTOMATIC_UPDATER_DISABLED true --raw --allow-root
    fi
    
    echo "[WordPress Core] Production settings applied"
else
    echo "[WordPress Core] Unknown environment: $WORDPRESS_ENV. Using custom debug settings from env variables..."
    
    # For custom environments, use env variables or safe defaults
    set_wp_config_boolean "WP_DEBUG" "$WORDPRESS_DEBUG" "false"
    set_wp_config_boolean "WP_DEBUG_LOG" "$WORDPRESS_DEBUG_LOG" "false"
    set_wp_config_boolean "WP_DEBUG_DISPLAY" "${WORDPRESS_DEBUG_DISPLAY:-$WORDPRESS_SHOW_WARNINGS}" "false"
    set_wp_config_boolean "SCRIPT_DEBUG" "$WORDPRESS_SCRIPT_DEBUG" "false"
    set_wp_config_boolean "SAVEQUERIES" "$WORDPRESS_SAVEQUERIES" "false"
fi

# Set environment variable
if ! wp config has WORDPRESS_ENV --allow-root 2>/dev/null; then
    wp config set WORDPRESS_ENV "$WORDPRESS_ENV" --allow-root
else
    wp config set WORDPRESS_ENV "$WORDPRESS_ENV" --allow-root
fi

# Log final debug configuration
echo "[WordPress Core] Final debug configuration:"
echo "  WP_DEBUG: $(wp config get WP_DEBUG --allow-root 2>/dev/null || echo 'not set')"
echo "  WP_DEBUG_LOG: $(wp config get WP_DEBUG_LOG --allow-root 2>/dev/null || echo 'not set')"
echo "  WP_DEBUG_DISPLAY: $(wp config get WP_DEBUG_DISPLAY --allow-root 2>/dev/null || echo 'not set')"
echo "  SCRIPT_DEBUG: $(wp config get SCRIPT_DEBUG --allow-root 2>/dev/null || echo 'not set')"
echo "  SAVEQUERIES: $(wp config get SAVEQUERIES --allow-root 2>/dev/null || echo 'not set')"

# Install WordPress if not already installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "[WordPress Core] Installing WordPress..."
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --allow-root
    
    echo "[WordPress Core] WordPress installation completed"
else
    echo "[WordPress Core] WordPress already installed"
fi

echo "[WordPress Core] WordPress core setup completed"

