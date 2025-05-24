#!/bin/bash

echo "[ConfigureRedis] Configuring Redis object cache..."

if [ -n "${WORDPRESS_REDIS_HOST:-}" ] && [ -n "${WORDPRESS_REDIS_PORT:-}" ]; then
    echo "[ConfigureRedis] Setting up Redis object cache with host: ${WORDPRESS_REDIS_HOST}, port: ${WORDPRESS_REDIS_PORT}"
    
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
    
    # Enable Redis cache
    wp redis enable --path="$WP_PATH" --allow-root --quiet 2>/dev/null || echo "[ConfigureRedis] Redis cache enable command completed (may show warnings if already enabled)"
    
    echo "[ConfigureRedis] Redis object cache configured and enabled."
else
    echo "[ConfigureRedis] Redis configuration variables not set. Skipping Redis setup."
fi
