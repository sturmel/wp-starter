#!/bin/bash

echo "[CustomScript] Starting WordPress initialization process..."

# Initialize Node.js environment
echo "[CustomScript] Initializing Node.js environment..."
export NVM_DIR=/usr/local/nvm
export NODE_VERSION=22.10.0
export PATH=$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Verify Node.js and npm are available
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    echo "[CustomScript] Node.js $(node --version) and npm $(npm --version) are available."
else
    echo "[CustomScript] Node.js or npm not found in PATH. Attempting to load NVM..."
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        . "$NVM_DIR/nvm.sh"
        nvm use default 2>/dev/null || nvm use node 2>/dev/null
        if command -v node &> /dev/null && command -v npm &> /dev/null; then
            echo "[CustomScript] Node.js $(node --version) and npm $(npm --version) loaded via NVM."
        else
            echo "[CustomScript WARNING] Node.js/npm still not available after loading NVM."
        fi
    else
        echo "[CustomScript WARNING] NVM not found. Node.js operations may fail."
    fi
fi

source /usr/local/bin/scripts/init-variables.sh

source /usr/local/bin/scripts/check-dependencies.sh

source /usr/local/bin/scripts/setup-wordpress-core.sh

echo "[CustomScript] Proceeding with Composer, Timber theme, and plugin installations... (Tools like git, unzip, msmtp, composer, node should be pre-installed from Dockerfile)"

source /usr/local/bin/scripts/configure-msmtp.sh

source /usr/local/bin/scripts/configure-redis.sh

source /usr/local/bin/scripts/manage-themes.sh

source /usr/local/bin/scripts/manage-plugins.sh

source /usr/local/bin/scripts/finalize-config.sh

echo "[CustomScript] Custom theme and plugin installation tasks complete."

echo "[CustomScript] Script finished. Starting main process (exec \"$@\")..."

exec "$@"
