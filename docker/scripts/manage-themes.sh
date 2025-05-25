#!/bin/bash

echo "[ManageThemes] Managing themes installation and activation..."

# Source template utilities
source /usr/local/bin/scripts/template-utils.sh

# Function to ensure composer install for a theme
ensure_composer_install() {
    local theme_path="$1"
    local theme_name="$2"
    if [ -d "${theme_path}" ]; then
        if [ ! -d "${theme_path}/vendor" ]; then
            echo "[ManageThemes] Vendor directory not found in ${theme_name} at ${theme_path}. Running composer install..."
            if [ -f "${theme_path}/composer.json" ]; then
                if command -v composer &> /dev/null; then
                    (cd "${theme_path}" && composer install --no-dev --prefer-dist)
                    echo "[ManageThemes] Composer install completed for ${theme_name}."
                else
                    echo "[ManageThemes WARNING] Composer not found. Cannot run composer install for ${theme_name}."
                fi
            else
                echo "[ManageThemes WARNING] composer.json not found in ${theme_name} at ${theme_path}. Cannot run composer install."
            fi
        else
            echo "[ManageThemes] Vendor directory already exists in ${theme_name} at ${theme_path}."
        fi
    else
        echo "[ManageThemes] Theme ${theme_name} not found at ${theme_path}. Skipping composer check."
    fi
}

# Ensure composer install for starter theme
ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}"

if [ "$CURRENT_ENV" = "development" ]; then
    echo "[ManageThemes] In development mode, ensuring Timber starter theme is present and custom theme is installed and active."

    # Install Timber starter theme if not present
    if [ ! -d "${STARTER_THEME_PATH}" ]; then
        echo "[ManageThemes] Timber Starter Theme not found at ${STARTER_THEME_PATH}. Installing..."
        mkdir -p "${THEMES_PATH}"
        if cd "${THEMES_PATH}"; then
            composer create-project upstatement/timber-starter-theme "${STARTER_THEME_SLUG}" --no-dev --prefer-dist
            echo "[ManageThemes] Timber Starter Theme installed in ${STARTER_THEME_PATH}."
            ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}" 
            cd "$OLDPWD"
        else
            echo "[ManageThemes ERROR] Could not cd to ${THEMES_PATH}. Cannot install Timber Starter Theme."
        fi
    else
        echo "[ManageThemes] Timber Starter Theme already exists at ${STARTER_THEME_PATH}."
        ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}" 
    fi

    # Create custom child theme if not present
    if [ ! -d "${CUSTOM_THEME_PATH}" ]; then
        echo "[ManageThemes] Child theme ${CUSTOM_THEME_SLUG} not found at ${CUSTOM_THEME_PATH}."
        if [ -d "${STARTER_THEME_PATH}" ]; then
            echo "[ManageThemes] Creating child theme ${CUSTOM_THEME_SLUG} from templates..."
            
            # Use template system to create the theme
            TEMPLATE_DIR="/usr/local/bin/scripts/../templates/custom-theme"
            if [ -d "$TEMPLATE_DIR" ]; then
                copy_template_directory "$TEMPLATE_DIR" "$CUSTOM_THEME_PATH"
                echo "[ManageThemes] Custom theme created from templates."
            else
                echo "[ManageThemes ERROR] Template directory not found: $TEMPLATE_DIR"
                return 1
            fi

            echo "[ManageThemes] Setting up Node.js environment and build tools in ${CUSTOM_THEME_PATH}..."
            ( 
                cd "${CUSTOM_THEME_PATH}" || { echo "[ManageThemes ERROR] Failed to cd into ${CUSTOM_THEME_PATH}"; exit 1; }

                # Verify Node.js and npm are available
                echo "[ManageThemes] Verifying Node.js and npm availability..."
                if ! command -v node &> /dev/null; then
                    echo "[ManageThemes ERROR] Node.js not found in PATH. Checking NVM..."
                    if [ -s "$NVM_DIR/nvm.sh" ]; then
                        echo "[ManageThemes] Loading NVM..."
                        . "$NVM_DIR/nvm.sh"
                        nvm use default 2>/dev/null || nvm use node 2>/dev/null
                    fi
                fi

                if ! command -v node &> /dev/null; then
                    echo "[ManageThemes ERROR] Node.js still not available. Cannot proceed with npm setup."
                    exit 1
                fi

                if ! command -v npm &> /dev/null; then
                    echo "[ManageThemes ERROR] npm not found. Cannot proceed with dependency installation."
                    exit 1
                fi

                echo "[ManageThemes] Node.js version: $(node --version)"
                echo "[ManageThemes] npm version: $(npm --version)"

                echo "[ManageThemes] Installing npm dependencies..."
                echo "[ManageThemes] Node.js version: $(node --version)"
                echo "[ManageThemes] npm version: $(npm --version)"
                
                if npm install 2>&1 | tee npm-install.log; then
                    echo "[ManageThemes] npm dependencies installed successfully."
                    rm -f npm-install.log
                else
                    echo "[ManageThemes ERROR] npm install failed. Full error log:"
                    echo "=================================="
                    cat npm-install.log
                    echo "=================================="
                    echo "[ManageThemes] Checking npm cache and permissions..."
                    echo "npm cache dir: $(npm config get cache)"
                    echo "npm prefix: $(npm config get prefix)"
                    echo "Current user: $(whoami)"
                    echo "Current user ID: $(id)"
                    echo "[ManageThemes] Attempting to continue without dependencies..."
                fi
            ) 
            echo "[ManageThemes] Node.js environment and build tools setup complete for ${CUSTOM_THEME_SLUG}."

        else
            echo "[ManageThemes ERROR] Cannot create child theme as parent theme ${STARTER_THEME_SLUG} does not exist at ${STARTER_THEME_PATH}."
        fi
    else
        echo "[ManageThemes] Custom theme ${CUSTOM_THEME_SLUG} already exists at ${CUSTOM_THEME_PATH}."
    fi

    # Activate custom theme
    if [ -d "${CUSTOM_THEME_PATH}" ]; then
        CUSTOM_THEME_STATUS=$(wp theme status "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root --field=status 2>/dev/null || echo "not-installed")
        if [ "$CUSTOM_THEME_STATUS" != "active" ]; then
            echo "[ManageThemes] Activating theme: ${CUSTOM_THEME_SLUG}"
            if wp theme activate "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[ManageThemes] Theme ${CUSTOM_THEME_SLUG} activated successfully."
            else
                echo "[ManageThemes WARNING] Failed to activate theme ${CUSTOM_THEME_SLUG}."
            fi
        else
            echo "[ManageThemes] Theme ${CUSTOM_THEME_SLUG} is already active."
        fi
    else
        echo "[ManageThemes WARNING] Custom theme ${CUSTOM_THEME_SLUG} not found. Cannot activate."
    fi

else  
    echo "[ManageThemes] In production mode. Ensuring custom theme is active if it exists, otherwise Timber starter, otherwise default."
    ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}"

    ACTIVE_THEME=$(wp theme list --status=active --field=name --path="${WP_PATH}" --allow-root 2>/dev/null || echo "")
    if [ -z "$ACTIVE_THEME" ] || [ "$ACTIVE_THEME" != "$CUSTOM_THEME_SLUG" ]; then
        echo "[ManageThemes WARNING] Active theme is '$ACTIVE_THEME'. Attempting to activate ${CUSTOM_THEME_SLUG} if present."
        if [ -d "${CUSTOM_THEME_PATH}" ]; then
            if wp theme activate "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[ManageThemes] Theme ${CUSTOM_THEME_SLUG} activated in production."
            else
                echo "[ManageThemes ERROR] Failed to activate ${CUSTOM_THEME_SLUG} in production. Trying ${STARTER_THEME_SLUG}."
                if [ -d "${STARTER_THEME_PATH}" ]; then
                    if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                        echo "[ManageThemes] Theme ${STARTER_THEME_SLUG} activated."
                    else
                        echo "[ManageThemes ERROR] Failed to activate ${STARTER_THEME_SLUG}. Manual intervention may be required."
                    fi
                else
                    DEFAULT_THEME=$(wp theme list --field=name --path="${WP_PATH}" --allow-root | head -n 1)
                    if [ -n "$DEFAULT_THEME" ]; then
                         echo "[ManageThemes WARNING] ${STARTER_THEME_SLUG} not found. Attempting to activate default theme: $DEFAULT_THEME"
                         if wp theme activate "$DEFAULT_THEME" --path="${WP_PATH}" --allow-root; then
                            echo "[ManageThemes] Default theme $DEFAULT_THEME activated."
                         else
                            echo "[ManageThemes ERROR] Failed to activate default theme $DEFAULT_THEME in production. Manual intervention required."
                         fi
                    else
                        echo "[ManageThemes ERROR] No themes found to activate in production. WordPress may not function correctly."
                    fi
                fi
            fi
        elif [ -d "${STARTER_THEME_PATH}" ]; then
             echo "[ManageThemes WARNING] Custom theme ${CUSTOM_THEME_SLUG} not found. Attempting to activate ${STARTER_THEME_SLUG}."
            if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[ManageThemes] Theme ${STARTER_THEME_SLUG} activated."
            else
                echo "[ManageThemes ERROR] Failed to activate ${STARTER_THEME_SLUG}. Manual intervention may be required."
            fi
        else
            DEFAULT_THEME=$(wp theme list --field=name --path="${WP_PATH}" --allow-root | head -n 1)
            if [ -n "$DEFAULT_THEME" ]; then
                 echo "[ManageThemes WARNING] Neither custom nor starter theme found. Attempting to activate default theme: $DEFAULT_THEME"
                 if wp theme activate "$DEFAULT_THEME" --path="${WP_PATH}" --allow-root; then
                    echo "[ManageThemes] Default theme $DEFAULT_THEME activated."
                 else
                    echo "[ManageThemes ERROR] Failed to activate default theme $DEFAULT_THEME in production. Manual intervention required."
                 fi
            else
                echo "[ManageThemes ERROR] No themes found to activate in production. WordPress may not function correctly."
            fi
        fi
    else
        echo "[ManageThemes] Active theme in production: $ACTIVE_THEME."
    fi
fi 

echo "[ManageThemes] Theme management complete."
