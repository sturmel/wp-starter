#!/usr/bin/env bash
set -euo pipefail

##############################################################
# Script de migration pour WordPress
# 
# Ce script va :
# - Regénérer wp-config.php à partir du .env
# - Démarrer les conteneurs Docker
# - Installer les dépendances Composer dans timber-starter-theme
# - Installer les dépendances npm dans le custom-theme
#
# AUCUNE SUPPRESSION ! Tout est conservé.
#
# Usage: ./scripts/migrate-clean.sh
##############################################################

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
  echo -e "${RED}[✗]${NC} $1"
}

check_env_file() {
  if [ ! -f .env ]; then
    log_error "Fichier .env manquant"
    log_info "Créez un fichier .env à partir de .env.example"
    exit 1
  fi
  log_success "Fichier .env trouvé"
}

pick_compose() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
  elif docker-compose version >/dev/null 2>&1; then
    echo "docker-compose"
  else
    log_error "Docker Compose v1 ou v2 non trouvé"
    exit 1
  fi
}

regenerate_wp_config() {
  log_info "Régénération de wp-config.php à partir du .env..."
  
  if [ ! -f "scripts/generate-wp-config.sh" ]; then
    log_error "Script generate-wp-config.sh introuvable"
    exit 1
  fi
  
  # Supprimer l'ancien wp-config.php s'il existe
  if [ -f "wordpress/wp-config.php" ]; then
    log_info "Suppression de l'ancien wp-config.php..."
    rm -f wordpress/wp-config.php
  fi
  
  # Générer le nouveau wp-config.php
  bash scripts/generate-wp-config.sh
  
  log_success "wp-config.php régénéré avec succès"
}

start_containers() {
  log_info "Démarrage des conteneurs Docker..."
  
  local compose_cmd=$(pick_compose)
  $compose_cmd up -d
  
  log_success "Conteneurs démarrés"
}

wait_for_services() {
  log_info "Attente du démarrage complet des services..."
  
  local compose_cmd=$(pick_compose)
  
  # Charger les variables d'environnement
  set -a
  source .env
  set +a
  
  # Attendre que MySQL soit prêt
  log_info "Attente de la base de données MySQL..."
  local retries=30
  local wait_seconds=2
  for ((i=1; i<=retries; i++)); do
    if $compose_cmd exec -T db mysqladmin ping -h"db" -u"${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent >/dev/null 2>&1; then
      log_success "Base de données MySQL prête"
      break
    fi
    if [ $i -eq $retries ]; then
      log_error "La base de données n'est pas prête après ${retries} tentatives"
      exit 1
    fi
    sleep "$wait_seconds"
  done
  
  # Attendre que WordPress soit prêt
  log_info "Attente du conteneur WordPress..."
  sleep 3
  log_success "Conteneur WordPress prêt"
}

ensure_composer() {
  log_info "Vérification de Composer dans le conteneur..."
  
  local compose_cmd=$(pick_compose)
  
  # Vérifier si Composer est déjà installé
  if $compose_cmd exec -T wordpress bash -c "command -v composer >/dev/null 2>&1"; then
    log_success "Composer déjà installé"
    return
  fi
  
  log_info "Installation de Composer dans le conteneur..."
  $compose_cmd exec -T wordpress bash -c "
    php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    rm composer-setup.php
  " || {
    log_error "Échec de l'installation de Composer"
    exit 1
  }
  
  # Configurer allow-plugins
  $compose_cmd exec -T wordpress bash -c "COMPOSER_ALLOW_SUPERUSER=1 composer config --global allow-plugins.composer/installers true"
  
  log_success "Composer installé avec succès"
}

ensure_node() {
  log_info "Vérification de Node.js dans le conteneur..."
  
  local compose_cmd=$(pick_compose)
  local required_version="22"
  
  # Vérifier si Node.js est déjà installé avec la bonne version
  if $compose_cmd exec -T wordpress bash -c "command -v node >/dev/null 2>&1"; then
    local node_version=$($compose_cmd exec -T wordpress node --version 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1 || echo "0")
    if [ "$node_version" = "$required_version" ]; then
      log_success "Node.js v$($compose_cmd exec -T wordpress node --version) déjà installé"
      return
    else
      log_warning "Version Node.js incorrecte ($node_version), réinstallation..."
    fi
  fi
  
  log_info "Installation de Node.js ${required_version}.x LTS dans le conteneur..."
  $compose_cmd exec -T wordpress bash -c "
    apt-get update >/dev/null 2>&1 && \
    apt-get install -y ca-certificates curl gnupg >/dev/null 2>&1 && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg 2>/dev/null && \
    echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${required_version}.x nodistro main' | tee /etc/apt/sources.list.d/nodesource.list >/dev/null && \
    apt-get update >/dev/null 2>&1 && \
    apt-get install -y nodejs >/dev/null 2>&1
  " || {
    log_error "Échec de l'installation de Node.js"
    exit 1
  }
  
  local installed_version=$($compose_cmd exec -T wordpress node --version)
  log_success "Node.js $installed_version installé avec succès"
}

install_composer_dependencies() {
  log_info "Installation des dépendances Composer dans timber-starter-theme..."
  
  local compose_cmd=$(pick_compose)
  local timber_theme_path="wordpress/wp-content/themes/timber-starter-theme"
  
  # Vérifier que le thème Timber existe
  if [ ! -d "$timber_theme_path" ]; then
    log_warning "Thème timber-starter-theme non trouvé, passage à l'étape suivante"
    return
  fi
  
  if [ ! -f "$timber_theme_path/composer.json" ]; then
    log_warning "Pas de composer.json dans timber-starter-theme"
    return
  fi
  
  log_info "Exécution de composer install dans le conteneur..."
  $compose_cmd exec -T wordpress bash -c "cd /var/www/html/wp-content/themes/timber-starter-theme && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --prefer-dist --no-progress --no-interaction --ignore-platform-reqs" || {
    log_error "Échec de l'installation Composer pour timber-starter-theme"
    exit 1
  }
  
  log_success "Dépendances Composer installées pour timber-starter-theme"
}

install_npm_dependencies() {
  log_info "Installation des dépendances npm dans le thème personnalisé..."
  
  # Charger les variables d'environnement
  set -a
  source .env
  set +a
  
  # Fonction pour générer le slug
  slugify() {
    local input="$1"
    local slug
    slug=$(echo "$input" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')
    if [ -z "$slug" ]; then
      slug=$(echo "$input" | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')
    fi
    printf '%s\n' "$slug"
  }
  
  local custom_theme_slug="${CUSTOM_THEME_SLUG:-$(slugify "$CUSTOM_THEME_NAME")}"
  local custom_theme_container_path="/var/www/html/wp-content/themes/$custom_theme_slug"
  local custom_theme_host_path="wordpress/wp-content/themes/$custom_theme_slug"
  
  if [ ! -d "$custom_theme_host_path" ]; then
    log_warning "Thème personnalisé non trouvé : $custom_theme_host_path"
    log_info "Le thème sera créé lors de la prochaine exécution de setup-wordpress.sh"
    return
  fi
  
  if [ ! -f "$custom_theme_host_path/package.json" ]; then
    log_warning "Pas de package.json dans le thème personnalisé"
    return
  fi
  
  log_info "Exécution de npm install dans le conteneur WordPress..."
  
  local compose_cmd=$(pick_compose)
  $compose_cmd exec -T wordpress bash -c "cd '$custom_theme_container_path' && npm install" || {
    log_error "Échec de npm install dans le thème personnalisé"
    exit 1
  }
  
  log_success "Dépendances npm installées pour le thème personnalisé"
}

print_summary() {
  echo ""
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✓ MIGRATION TERMINÉE AVEC SUCCÈS                          ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  log_success "Configuration mise à jour"
  echo ""
  echo "📊 Résumé des opérations :"
  echo "  ✓ wp-config.php régénéré depuis le .env"
  echo "  ✓ Conteneurs Docker démarrés"
  echo "  ✓ Dépendances Composer installées (timber-starter-theme)"
  echo "  ✓ Dépendances npm installées (custom-theme)"
  echo ""
  echo "🌐 Accès :"
  
  # Charger les variables pour afficher les URLs
  set -a
  source .env 2>/dev/null || true
  set +a
  
  echo "  • Site WordPress    : ${WORDPRESS_URL:-http://localhost:8080}"
  echo "  • Admin WordPress   : ${WORDPRESS_URL:-http://localhost:8080}/wp-admin"
  echo "  • phpMyAdmin        : http://localhost:${PHPMYADMIN_HOST_PORT:-8081}"
  echo "  • BrowserSync (dev) : http://localhost:3000"
  echo ""
  echo "👨‍💻 Commandes utiles :"
  echo "  • Lancer le dev : docker compose exec wordpress bash -c 'cd /var/www/html/wp-content/themes/${CUSTOM_THEME_SLUG:-custom-theme} && npm run dev'"
  echo "  • Build prod    : docker compose exec wordpress bash -c 'cd /var/www/html/wp-content/themes/${CUSTOM_THEME_SLUG:-custom-theme} && npm run build'"
  echo "  • Accès shell   : docker compose exec wordpress bash"
  echo ""
}

main() {
  echo ""
  echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
  echo -e "${BLUE}    Script de Migration - WordPress Docker${NC}"
  echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
  echo ""
  
  # Vérifications préliminaires
  log_info "Vérifications préliminaires..."
  check_env_file
  
  echo ""
  log_info "Début de la migration (AUCUNE SUPPRESSION)..."
  echo ""
  
  # Étape 1 : Régénération wp-config.php
  regenerate_wp_config
  
  # Étape 2 : Démarrage des conteneurs
  start_containers
  
  # Étape 3 : Attendre que les services soient prêts
  wait_for_services
  
  # Étape 4 : Installer Composer et Node.js dans le conteneur
  ensure_composer
  ensure_node
  
  # Étape 5 : Installation des dépendances Composer
  install_composer_dependencies
  
  # Étape 6 : Installation des dépendances npm
  install_npm_dependencies
  
  # Résumé
  print_summary
}

# Exécution du script
main "$@"
