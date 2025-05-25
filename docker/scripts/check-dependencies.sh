#!/bin/bash

echo "[CheckDependencies] Checking dependencies..."

# Check for mysqladmin
if ! command -v mysqladmin &> /dev/null
then
    echo "[CheckDependencies] mysqladmin could not be found. Installing mysql-client..."
    apt-get update && apt-get install -y default-mysql-client
    if ! command -v mysqladmin &> /dev/null
    then
        echo "[CheckDependencies ERROR] Failed to install mysql-client. Please install it manually in the Docker image."
        exit 1
    fi
    echo "[CheckDependencies] mysql-client installed."
fi

# Wait for MySQL to be ready
echo "[CheckDependencies] Waiting for MySQL to be ready..."
until mysqladmin ping -h"db" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent; do
    echo "[CheckDependencies] MySQL is unavailable - sleeping"
    sleep 5
done
echo "[CheckDependencies] MySQL is up - continuing..."

# Wait for Redis to be ready
if [ -n "${WORDPRESS_REDIS_HOST:-}" ]; then
    echo "[CheckDependencies] Waiting for Redis to be ready..."
    until timeout 5 bash -c "echo > /dev/tcp/${WORDPRESS_REDIS_HOST}/${WORDPRESS_REDIS_PORT:-6379}"; do
        echo "[CheckDependencies] Redis is unavailable - sleeping"
        sleep 2
    done
    echo "[CheckDependencies] Redis is up - continuing..."
else
    echo "[CheckDependencies] Redis configuration not set, skipping Redis check."
fi

# Check for required tools
REQUIRED_TOOLS=("wp" "composer" "node" "npm")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "[CheckDependencies WARNING] $tool not found but should be pre-installed from Dockerfile"
    else
        echo "[CheckDependencies] $tool is available"
    fi
done

echo "[CheckDependencies] Dependencies check complete."
