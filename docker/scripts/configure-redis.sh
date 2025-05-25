#!/bin/bash

echo "[ConfigureRedis] Configuring Redis object cache..."

if [ -n "${WORDPRESS_REDIS_HOST:-}" ] && [ -n "${WORDPRESS_REDIS_PORT:-}" ]; then
    echo "[ConfigureRedis] Setting up Redis object cache with host: ${WORDPRESS_REDIS_HOST}, port: ${WORDPRESS_REDIS_PORT}"
    
    # Ensure Redis connection works before proceeding
    echo "[ConfigureRedis] Testing Redis connection..."
    if ! timeout 10 bash -c "echo > /dev/tcp/${WORDPRESS_REDIS_HOST}/${WORDPRESS_REDIS_PORT}"; then
        echo "[ConfigureRedis] WARNING: Cannot connect to Redis. Skipping Redis setup."
        return 0
    fi
    
    wp config set WP_REDIS_HOST "${WORDPRESS_REDIS_HOST}" --path="$WP_PATH" --allow-root --quiet
    wp config set WP_REDIS_PORT "${WORDPRESS_REDIS_PORT}" --path="$WP_PATH" --allow-root --quiet
    
    # Install and activate redis-cache plugin if not already installed
    if ! wp plugin is-installed redis-cache --path="$WP_PATH" --allow-root --quiet; then
        wp plugin install redis-cache --activate --path="$WP_PATH" --allow-root --quiet
        echo "[ConfigureRedis] Redis Cache plugin installed and activated."
    elif ! wp plugin is-active redis-cache --path="$WP_PATH" --allow-root --quiet; then
        wp plugin activate redis-cache --path="$WP_PATH" --allow-root --quiet
        echo "[ConfigureRedis] Redis Cache plugin activated."
    fi
    
    # Enable Redis cache - this will create the object-cache.php file
    if wp redis enable --path="$WP_PATH" --allow-root --quiet 2>/dev/null; then
        echo "[ConfigureRedis] Redis cache enabled successfully."
    else
        echo "[ConfigureRedis] Warning: Redis cache enable command had issues, but continuing..."
    fi
    
    # Test Redis connection after enabling
    if wp redis status --path="$WP_PATH" --allow-root --quiet 2>/dev/null; then
        echo "[ConfigureRedis] Redis connection test successful."
    else
        echo "[ConfigureRedis] Warning: Redis connection test failed, but object cache is configured."
    fi
    
    echo "[ConfigureRedis] Redis object cache configuration complete."
else
    echo "[ConfigureRedis] Redis configuration variables not set. Skipping Redis setup."
fi
