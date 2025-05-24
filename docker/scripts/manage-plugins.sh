#!/bin/bash

echo "[ManagePlugins] Managing plugins installation and activation..."

# Define plugins to install
PLUGINS_TO_INSTALL=(
  "advanced-custom-fields"
  "wordpress-seo"
  "litespeed-cache"
  "contact-form-7"
)

if [ "$CURRENT_ENV" = "development" ]; then
    echo "[ManagePlugins] In development mode, ensuring plugins are installed and active."
    for plugin_slug in "${PLUGINS_TO_INSTALL[@]}"; do
      if ! wp plugin is-installed "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
        echo "[ManagePlugins] Installing plugin $plugin_slug..."
        wp plugin install "$plugin_slug" --activate --path="$WP_PATH" --allow-root || echo "[ManagePlugins WARNING] Failed to install/activate plugin $plugin_slug."
      elif ! wp plugin is-active "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
        echo "[ManagePlugins] Activating plugin $plugin_slug..."
        wp plugin activate "$plugin_slug" --path="$WP_PATH" --allow-root || echo "[ManagePlugins WARNING] Failed to activate plugin $plugin_slug."
      else
        echo "[ManagePlugins] Plugin $plugin_slug is already installed and active."
      fi
    done
else
    echo "[ManagePlugins] In production mode, ensuring plugins are active if already installed."
    for plugin_slug in "${PLUGINS_TO_INSTALL[@]}"; do
        if wp plugin is-installed "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
            if ! wp plugin is-active "$plugin_slug" --path="$WP_PATH" --allow-root --quiet; then
                echo "[ManagePlugins] Activating plugin $plugin_slug in production..."
                wp plugin activate "$plugin_slug" --path="$WP_PATH" --allow-root || echo "[ManagePlugins WARNING] Failed to activate plugin $plugin_slug in production."
            else
                echo "[ManagePlugins] Plugin $plugin_slug is already active in production."
            fi
        else
            echo "[ManagePlugins] Plugin $plugin_slug not installed in production. Skipping activation."
        fi
    done
fi

echo "[ManagePlugins] Plugin management complete."
