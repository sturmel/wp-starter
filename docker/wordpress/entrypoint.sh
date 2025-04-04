#!/bin/bash

# Set errexit to exit immediately if a command exits with a non-zero status
set -e

# Load NVM environment
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Check if the html directory is empty
if [ "$(ls -A /var/www/html)" ]; then
  echo "html directory is not empty. Skipping installation."
else
  echo "html directory is empty. Installing WordPress..."

  wp core download --path=/var/www/html --locale=fr_FR --version=latest --allow-root

  # Create wp-config.php
  wp config create --path=/var/www/html --dbname=${WORDPRESS_DB_NAME} --dbuser=${WORDPRESS_DB_USER} --dbpass=${WORDPRESS_DB_PASSWORD} --dbhost=${WORDPRESS_DB_HOST} --locale=fr_FR --skip-check --allow-root

  # Install WordPress
  wp core install --path=/var/www/html --url=${WORDPRESS_SITE_URL} --title=${WORDPRESS_SITE_NAME} --admin_user=${WORDPRESS_ADMIN_USER} --admin_password=${WORDPRESS_ADMIN_PASSWORD} --admin_email=${WORDPRESS_ADMIN_EMAIL} --allow-root

  # Install plugins
  wp plugin install wordpress-seo --allow-root
  wp plugin install wordfence --allow-root
  wp plugin install contact-form-7 --allow-root
  wp plugin install complianz-gdpr --allow-root
  wp plugin install w3-total-cache --allow-root
  wp plugin install all-in-one-wp-migration --allow-root
  wp plugin install advanced-custom-fields --allow-root

  wp plugin uninstall hello --allow-root

  cd /var/www/html/wp-content/themes
  composer create-project upstatement/timber-starter-theme --no-dev
fi

# Start Apache
exec apache2-foreground