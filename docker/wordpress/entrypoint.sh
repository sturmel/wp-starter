#!/bin/bash

# Set errexit to exit immediately if a command exits with a non-zero status
set -e

# Check if the html directory is empty
if [ "$(ls -A /var/www/html)" ]; then
  echo "html directory is not empty. Skipping Bedrock installation."
else
  echo "html directory is empty. Installing Bedrock..."

  # Download Bedrock
  cd /var/www/html
  composer create-project roots/bedrock . --no-install

  # Create .env file
  cat <<EOF > .env
DB_NAME='wordpress'
DB_USER='docker'
DB_PASSWORD='password'

# Optionally, you can use a data source name (DSN)
# When using a DSN, you can remove the DB_NAME, DB_USER, DB_PASSWORD, and DB_HOST variables
# DATABASE_URL='mysql://database_user:database_password@database_host:database_port/database_name'

# Optional database variables
DB_HOST='wordpress_db'
# DB_PREFIX='wp_'

WP_ENV='development'
WP_HOME='http://localhost:8101'
WP_SITEURL="\${WP_HOME}/wp"

# Specify optional debug.log path
# WP_DEBUG_LOG='/path/to/debug.log'

# Generate your keys here: https://roots.io/salts.html
AUTH_KEY='mLK<Fu2?x%g>X1&i;AFxMC\`((4_Ky^GR&+Vx8fKsL}{9()E=*-GBTQbJYp@Ashm'
SECURE_AUTH_KEY='M^90OncZY|Spq6212WdEqg_|iY9u1TQ}P=hiSI<.b{b=}5^*O+(!bm\$MUg[iH\`#8'
LOGGED_IN_KEY='mEv@^nMF>EIe]3mZ\`<d5;{Xq.CRf^w#+.wz.YTSn@0xOVd|Hyt;wZ@PNgUWcv}&q'
NONCE_KEY='Nh<eD;63Fik]2{2Stb-A1YBdjkLyt*{.}QGnHBF<o3Q@kgB72B\$\`;wwqNGEWyD9m'
AUTH_SALT='k17_qIJ=a#>F+:BiQxL{N^1fbpBH;L+Bl5owAVTpCZ%x0P}cDwxX-\$_u-9lk*wlu'
SECURE_AUTH_SALT='#v,y(FmjVu02D^+6+pely9UDaRe:d5N^/_he%*h2vRms7%bq>zZ26_cpRwGW@DoY'
LOGGED_IN_SALT='1RjfB!HH?0y__:\$#W20B2Y9CCnDh2iIehzS2h]:gfALrI!R4.ZEuG@R:0poiQ>*P'
NONCE_SALT='9axzFiKmWEL)IXki&{Nd5:cB;eUU3nsRfd?xE.\`!(,+FslJ_#Q)v(|3*c#eG,&f!'
EOF

  # Install Composer dependencies
  composer install --no-dev --optimize-autoloader
  composer require wpackagist-plugin/wordpress-seo
  composer require wpackagist-plugin/wordfence
  composer require wpackagist-plugin/contact-form-7
  composer require wpackagist-plugin/complianz-gdpr
  composer require wpackagist-plugin/w3-total-cache
  composer require wpackagist-plugin/all-in-one-wp-migration
  composer require wpackagist-plugin/advanced-custom-fields

  cd web/app/themes

  composer create-project roots/sage lugh-web

  echo "Bedrock installed successfully!"
fi

# Start Apache
exec apache2-foreground