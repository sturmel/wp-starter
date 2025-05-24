#!/bin/bash

echo "[FinalizeConfig] Finalizing WordPress configuration..."

# Configuration constants to add
ALL_CONFIG_ADDITIONS="" 

# Add WP_CACHE if not present
if ! grep -q "define( *'WP_CACHE' *, *true *);" "$WP_CONFIG_FILE"; then
    ALL_CONFIG_ADDITIONS="define( 'WP_CACHE', true );"
fi

# Add environment-specific configurations
if [ "$CURRENT_ENV" = "production" ]; then
    ALL_CONFIG_ADDITIONS="${ALL_CONFIG_ADDITIONS}\ndefine( 'AUTOMATIC_UPDATER_DISABLED', true );\ndefine( 'DISALLOW_FILE_MODS', true );"
elif [ "$CURRENT_ENV" = "development" ]; then 
    ALL_CONFIG_ADDITIONS="${ALL_CONFIG_ADDITIONS}\ndefine( 'AUTOMATIC_UPDATER_DISABLED', false );\ndefine( 'DISALLOW_FILE_MODS', false );"
fi

# Apply configuration additions
if [ -f "$WP_CONFIG_FILE" ]; then
    echo "[FinalizeConfig] Configuration constants will be applied to $WP_CONFIG_FILE."

    if [ -n "$ALL_CONFIG_ADDITIONS" ]; then
        # Check if AUTOMATIC_UPDATER_DISABLED is already defined to avoid duplicates
        if ! grep -q "define( *'AUTOMATIC_UPDATER_DISABLED'" "$WP_CONFIG_FILE"; then
            echo -e "\n${ALL_CONFIG_ADDITIONS}" >> "$WP_CONFIG_FILE"
            echo "[FinalizeConfig] Added environment-specific constants to $WP_CONFIG_FILE."
        else
            echo "[FinalizeConfig] Configuration constants already present in $WP_CONFIG_FILE."
        fi
    fi
else
    echo "[FinalizeConfig WARNING] $WP_CONFIG_FILE not found. Cannot apply configuration."
fi

echo "[FinalizeConfig] WordPress configuration finalized for environment: $CURRENT_ENV"
