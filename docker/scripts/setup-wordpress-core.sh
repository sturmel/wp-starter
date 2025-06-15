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

# Configure debug settings based on environment
if [ "$WORDPRESS_ENV" = "development" ]; then
    echo "[WordPress Core] Configuring DEBUG settings for development environment..."
    
    # Force direct file system method to avoid FTP prompts
    if ! wp config has FS_METHOD --allow-root 2>/dev/null; then
        wp config set FS_METHOD direct --allow-root
    else
        wp config set FS_METHOD direct --allow-root
    fi
    
    # Enable debug mode - check if constants exist first
    if ! wp config has WP_DEBUG --allow-root 2>/dev/null; then
        wp config set WP_DEBUG true --raw --allow-root
    else
        wp config set WP_DEBUG true --raw --allow-root
    fi
    
    if ! wp config has WP_DEBUG_LOG --allow-root 2>/dev/null; then
        wp config set WP_DEBUG_LOG true --raw --allow-root
    else
        wp config set WP_DEBUG_LOG true --raw --allow-root
    fi
    
    # Control warnings display based on WORDPRESS_SHOW_WARNINGS
    if [ "${WORDPRESS_SHOW_WARNINGS:-false}" = "true" ]; then
        echo "[WordPress Core] Warnings display enabled"
        if ! wp config has WP_DEBUG_DISPLAY --allow-root 2>/dev/null; then
            wp config set WP_DEBUG_DISPLAY true --raw --allow-root
        else
            wp config set WP_DEBUG_DISPLAY true --raw --allow-root
        fi
    else
        echo "[WordPress Core] Warnings display disabled"
        if ! wp config has WP_DEBUG_DISPLAY --allow-root 2>/dev/null; then
            wp config set WP_DEBUG_DISPLAY false --raw --allow-root
        else
            wp config set WP_DEBUG_DISPLAY false --raw --allow-root
        fi
    fi
    
    if ! wp config has SCRIPT_DEBUG --allow-root 2>/dev/null; then
        wp config set SCRIPT_DEBUG true --raw --allow-root
    else
        wp config set SCRIPT_DEBUG true --raw --allow-root
    fi
    
    if ! wp config has SAVEQUERIES --allow-root 2>/dev/null; then
        wp config set SAVEQUERIES true --raw --allow-root
    else
        wp config set SAVEQUERIES true --raw --allow-root
    fi
    
    # Remove WP_CACHE if it exists to avoid conflicts
    if wp config has WP_CACHE --allow-root 2>/dev/null; then
        wp config delete WP_CACHE --allow-root 2>/dev/null || true
    fi
    
    # Create debug directory if it doesn't exist
    mkdir -p /var/www/html/wp-content/debug
    chmod 755 /var/www/html/wp-content/debug
    
    echo "[WordPress Core] DEBUG mode enabled for development"
    
elif [ "$WORDPRESS_ENV" = "production" ]; then
    echo "[WordPress Core] Configuring settings for production environment..."
    
    # Disable debug mode - check if constants exist first
    if ! wp config has WP_DEBUG --allow-root 2>/dev/null; then
        wp config set WP_DEBUG false --raw --allow-root
    else
        wp config set WP_DEBUG false --raw --allow-root
    fi
    
    if ! wp config has WP_DEBUG_LOG --allow-root 2>/dev/null; then
        wp config set WP_DEBUG_LOG false --raw --allow-root
    else
        wp config set WP_DEBUG_LOG false --raw --allow-root
    fi
    
    # In production, respect WORDPRESS_SHOW_WARNINGS for critical debugging
    if [ "${WORDPRESS_SHOW_WARNINGS:-false}" = "true" ]; then
        echo "[WordPress Core] Warnings display enabled for production debugging"
        if ! wp config has WP_DEBUG_DISPLAY --allow-root 2>/dev/null; then
            wp config set WP_DEBUG_DISPLAY true --raw --allow-root
        else
            wp config set WP_DEBUG_DISPLAY true --raw --allow-root
        fi
    else
        echo "[WordPress Core] Warnings display disabled for production"
        if ! wp config has WP_DEBUG_DISPLAY --allow-root 2>/dev/null; then
            wp config set WP_DEBUG_DISPLAY false --raw --allow-root
        else
            wp config set WP_DEBUG_DISPLAY false --raw --allow-root
        fi
    fi
    
    if ! wp config has SCRIPT_DEBUG --allow-root 2>/dev/null; then
        wp config set SCRIPT_DEBUG false --raw --allow-root
    else
        wp config set SCRIPT_DEBUG false --raw --allow-root
    fi
    
    if ! wp config has SAVEQUERIES --allow-root 2>/dev/null; then
        wp config set SAVEQUERIES false --raw --allow-root
    else
        wp config set SAVEQUERIES false --raw --allow-root
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
    
    if ! wp config has DISALLOW_FILE_MODS --allow-root 2>/dev/null; then
        wp config set DISALLOW_FILE_MODS true --raw --allow-root
    else
        wp config set DISALLOW_FILE_MODS true --raw --allow-root
    fi
    
    if ! wp config has AUTOMATIC_UPDATER_DISABLED --allow-root 2>/dev/null; then
        wp config set AUTOMATIC_UPDATER_DISABLED true --raw --allow-root
    else
        wp config set AUTOMATIC_UPDATER_DISABLED true --raw --allow-root
    fi
    
    echo "[WordPress Core] Production settings applied"
fi

# Set environment variable
if ! wp config has WORDPRESS_ENV --allow-root 2>/dev/null; then
    wp config set WORDPRESS_ENV "$WORDPRESS_ENV" --allow-root
else
    wp config set WORDPRESS_ENV "$WORDPRESS_ENV" --allow-root
fi

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
