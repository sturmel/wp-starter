#!/bin/bash

# Set errexit to exit immediately if a command exits with a non-zero status
set -e

# Check if the html directory is empty
if [ "$(ls -A /var/www/html)" ]; then
  echo "html directory is not empty. Skipping WordPress installation."
else
  echo "html directory is empty. Installing WordPress..."

  # Download WordPress
  wp core download --locale=fr_FR --path=/var/www/html --force --allow-root

  # Create wp-config.php
  wp config create --dbname=wordpress --dbuser=docker --dbpass=password --dbhost=wordpress_db --locale=fr_FR --path=/var/www/html --allow-root

  # Install WordPress
  wp core install --title="My WordPress Site" --admin_user=admin --admin_password=password --admin_email=admin@example.com --url=http://localhost:8101 --path=/var/www/html --allow-root
  
  # Install plugins
  wp plugin install advanced-custom-fields --path=/var/www/html --allow-root
  wp plugin install wordpress-seo --path=/var/www/html --allow-root
  wp plugin install wordfence --path=/var/www/html --allow-root
  wp plugin install contact-form-7 --path=/var/www/html --allow-root
  wp plugin install complianz-gdpr --path=/var/www/html --allow-root
  wp plugin install w3-total-cache --path=/var/www/html --allow-root
  wp plugin install all-in-one-wp-migration --path=/var/www/html --allow-root

  # Activate plugins
  wp plugin activate advanced-custom-fields --path=/var/www/html --allow-root
  wp plugin activate wordpress-seo --path=/var/www/html --allow-root
  wp plugin activate wordfence --path=/var/www/html --allow-root
  wp plugin activate contact-form-7 --path=/var/www/html --allow-root
  wp plugin activate complianz-gdpr --path=/var/www/html --allow-root
  wp plugin activate w3-total-cache --path=/var/www/html --allow-root
  wp plugin activate all-in-one-wp-migration --path=/var/www/html --allow-root

  # Uninstall Hello Dolly plugin
  wp plugin uninstall hello --path=/var/www/html --allow-root
  
  echo "WordPress installed successfully!"
fi

# Start Apache
exec apache2-foreground