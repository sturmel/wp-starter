#!/bin/bash

##############################################################
# Script pour générer wp-config.php à partir du .env
# Usage: ./scripts/generate-wp-config.sh
##############################################################

set -e

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Chemins
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/.env"
WP_CONFIG_FILE="$PROJECT_ROOT/wordpress/wp-config.php"

echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}Génération de wp-config.php à partir du .env${NC}"
echo -e "${GREEN}==================================================${NC}"

# Vérifier que le fichier .env existe
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${RED}✗ Erreur: Le fichier .env n'existe pas${NC}"
    echo -e "${YELLOW}Créez un fichier .env à partir de .env.example${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Fichier .env trouvé"

# Charger les variables d'environnement
echo -e "${GREEN}→${NC} Chargement des variables d'environnement..."
set -a
source "$ENV_FILE"
set +a

# Vérifier que les variables nécessaires sont définies
REQUIRED_VARS=("WORDPRESS_DB_NAME" "WORDPRESS_DB_USER" "WORDPRESS_DB_PASSWORD")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${RED}✗ Erreur: Variables manquantes dans .env:${NC}"
    for var in "${MISSING_VARS[@]}"; do
        echo -e "${RED}  - $var${NC}"
    done
    exit 1
fi

echo -e "${GREEN}✓${NC} Variables d'environnement chargées"

# Définir les valeurs par défaut (ne pas utiliser des variables qui n'existent pas)
DB_HOST="db:3306"
TABLE_PREFIX="${WORDPRESS_TABLE_PREFIX:-wp_}"
WP_DEBUG="false"

# Générer les clés de sécurité WordPress
echo -e "${GREEN}→${NC} Génération des clés de sécurité WordPress..."
SALT_KEYS=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)

if [ -z "$SALT_KEYS" ]; then
    echo -e "${YELLOW}⚠ Impossible de générer les clés depuis WordPress.org${NC}"
    echo -e "${YELLOW}  Utilisation de clés aléatoires locales${NC}"
    
    # Fonction pour générer une clé aléatoire
    generate_key() {
        openssl rand -base64 64 | tr -d '\n'
    }
    
    SALT_KEYS="define('AUTH_KEY',         '$(generate_key)');
define('SECURE_AUTH_KEY',  '$(generate_key)');
define('LOGGED_IN_KEY',    '$(generate_key)');
define('NONCE_KEY',        '$(generate_key)');
define('AUTH_SALT',        '$(generate_key)');
define('SECURE_AUTH_SALT', '$(generate_key)');
define('LOGGED_IN_SALT',   '$(generate_key)');
define('NONCE_SALT',       '$(generate_key)');"
fi

echo -e "${GREEN}✓${NC} Clés de sécurité générées"

# Créer le fichier wp-config.php
echo -e "${GREEN}→${NC} Création du fichier wp-config.php..."

cat > "$WP_CONFIG_FILE" << 'EOF'
<?php
/**
 * The base configuration for WordPress
 *
 * This file has been automatically generated from environment variables.
 * DO NOT commit this file to version control.
 *
 * @package WordPress
 */

EOF

cat >> "$WP_CONFIG_FILE" << EOF
// ** Database settings ** //
define( 'DB_NAME', '${WORDPRESS_DB_NAME}' );
define( 'DB_USER', '${WORDPRESS_DB_USER}' );
define( 'DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}' );
define( 'DB_HOST', '${DB_HOST}' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 */
${SALT_KEYS}
/**#@-*/

/**
 * WordPress database table prefix.
 */
\$table_prefix = '${TABLE_PREFIX}';

/**
 * For developers: WordPress debugging mode.
 */
define( 'WP_DEBUG', ${WP_DEBUG} );
EOF

# Ajouter la configuration Redis si disponible
if [ "${REDIS_ENABLED:-false}" = "true" ]; then
    cat >> "$WP_CONFIG_FILE" << 'EOF'

/**
 * Redis Object Cache configuration
 */
define( 'WP_REDIS_HOST', 'redis' );
define( 'WP_REDIS_PORT', 6379 );
define( 'WP_CACHE', true );
EOF
fi

# Ajouter la configuration multisite si nécessaire
if [ "${WP_MULTISITE:-false}" = "true" ]; then
    cat >> "$WP_CONFIG_FILE" << EOF

/**
 * Multisite configuration
 */
define( 'WP_ALLOW_MULTISITE', true );
define( 'MULTISITE', true );
define( 'SUBDOMAIN_INSTALL', ${WP_SUBDOMAIN_INSTALL:-false} );
define( 'DOMAIN_CURRENT_SITE', '${DOMAIN_CURRENT_SITE:-localhost}' );
define( 'PATH_CURRENT_SITE', '/' );
define( 'SITE_ID_CURRENT_SITE', 1 );
define( 'BLOG_ID_CURRENT_SITE', 1 );
EOF
fi

# Finaliser le fichier
cat >> "$WP_CONFIG_FILE" << 'EOF'

/* Add any custom values between this line and the "stop editing" line. */

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF

echo -e "${GREEN}✓${NC} Fichier wp-config.php créé avec succès"

# Définir les permissions appropriées
chmod 644 "$WP_CONFIG_FILE"
echo -e "${GREEN}✓${NC} Permissions définies (644)"

echo ""
echo -e "${GREEN}==================================================${NC}"
echo -e "${GREEN}✓ Configuration terminée avec succès !${NC}"
echo -e "${GREEN}==================================================${NC}"
echo ""
echo -e "${YELLOW}Fichier généré: ${NC}$WP_CONFIG_FILE"
echo -e "${YELLOW}Base de données:${NC} $WORDPRESS_DB_NAME"
echo -e "${YELLOW}Utilisateur DB: ${NC} $WORDPRESS_DB_USER"
echo -e "${YELLOW}Préfixe tables:${NC} $TABLE_PREFIX"
echo ""
echo -e "${RED}⚠ IMPORTANT: Ne commitez PAS wp-config.php dans Git${NC}"
echo ""
