#!/bin/bash

echo "[InitVariables] Initializing variables..."

# Set error handling
set -e

# WordPress paths
export WP_PATH=/var/www/html
export WP_CONTENT_PATH=${WP_PATH}/wp-content
export THEMES_PATH=${WP_CONTENT_PATH}/themes
export PLUGINS_PATH=${WP_CONTENT_PATH}/plugins

# Theme configuration
export TIMBER_THEME_DIR_NAME="timber"
export TIMBER_REPO_URL="https://github.com/timber/timber.git"
export STARTER_THEME_SLUG="timber-starter-theme"
export CUSTOM_THEME_SLUG="${CUSTOM_THEME_NAME:-custom-timber-theme}"

# Path variables
export STARTER_THEME_PATH="${THEMES_PATH}/${STARTER_THEME_SLUG}"
export CUSTOM_THEME_PATH="${THEMES_PATH}/${CUSTOM_THEME_SLUG}"
export WP_CONFIG_FILE="${WP_PATH}/wp-config.php"

# Environment
export CURRENT_ENV="${WORDPRESS_ENV:-development}"
export WORDPRESS_HOST_PORT="${WORDPRESS_HOST_PORT:-8080}"

echo "[InitVariables] Variables initialized:"
echo "  WP_PATH: $WP_PATH"
echo "  WP_CONTENT_PATH: $WP_CONTENT_PATH"
echo "  CUSTOM_THEME_SLUG: $CUSTOM_THEME_SLUG"
echo "  STARTER_THEME_SLUG: $STARTER_THEME_SLUG"
echo "  CURRENT_ENV: $CURRENT_ENV"
echo "  WORDPRESS_HOST_PORT: $WORDPRESS_HOST_PORT"
