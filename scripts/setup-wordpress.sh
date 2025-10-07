#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
WORDPRESS_DIR="$PROJECT_ROOT/wordpress"

log() {
  printf '\n[setup-wordpress] %s\n' "$1"
}

require_env_var() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "[setup-wordpress ERROR] Missing required environment variable: $name" >&2
    exit 1
  fi
}

slugify() {
  local input="$1"
  local slug
  slug=$(echo "$input" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')
  if [ -z "$slug" ]; then
    slug=$(echo "$input" | sed -E 's/[^a-zA-Z0-9]+/-/g' | sed -E 's/^-+|-+$//g' | tr '[:upper:]' '[:lower:]')
  fi
  printf '%s\n' "$slug"
}

pick_compose() {
  if docker compose version >/dev/null 2>&1; then
    echo "docker compose"
    return 0
  fi
  if docker-compose version >/dev/null 2>&1; then
    echo "docker-compose"
    return 0
  fi
  echo "[setup-wordpress ERROR] Docker Compose v1 or v2 not found. Install Docker Compose first." >&2
  exit 1
}

apply_template_variables() {
  local directory="$1"
  local relative_path="${directory#$WORDPRESS_DIR/}"

  local php_code
  php_code=$(cat <<'PHP'
$relative = getenv('THEME_RELATIVE');
$base = trailingslashit(ABSPATH) . $relative;
$themeSlug = getenv('CUSTOM_THEME_SLUG');
$starterSlug = getenv('STARTER_THEME_SLUG');
$hostPort = getenv('WORDPRESS_HOST_PORT');

if (!is_dir($base)) {
  fwrite(STDERR, "[setup-wordpress PHP] Directory not found: {$base}\n");
  return;
}

$iterator = new RecursiveIteratorIterator(
  new RecursiveDirectoryIterator($base, FilesystemIterator::SKIP_DOTS)
);

foreach ($iterator as $file) {
  if (!$file->isFile()) {
    continue;
  }

  $path = $file->getPathname();
  $contents = file_get_contents($path);
  $replaced = str_replace(
    ['{{CUSTOM_THEME_SLUG}}', '{{STARTER_THEME_SLUG}}', '{{WORDPRESS_HOST_PORT}}'],
    [$themeSlug, $starterSlug, $hostPort],
    $contents
  );

  if ($replaced !== $contents) {
    file_put_contents($path, $replaced);
  }
}
PHP
  )

  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress env \
  CUSTOM_THEME_SLUG="$CUSTOM_THEME_SLUG" \
  STARTER_THEME_SLUG="$STARTER_THEME_SLUG" \
  WORDPRESS_HOST_PORT="$WORDPRESS_HOST_PORT" \
  THEME_RELATIVE="$relative_path" \
  wp --allow-root eval --skip-themes --skip-plugins "$php_code"
}

copy_template_directory() {
  local template_dir="$1"
  local destination="$2"
  if [ ! -d "$template_dir" ]; then
    echo "[setup-wordpress ERROR] Template directory not found: $template_dir" >&2
    exit 1
  fi
  find "$template_dir" -type f -print0 | while IFS= read -r -d '' file; do
    local relative="${file#$template_dir/}"
    local output="$destination/$relative"
    mkdir -p "$(dirname "$output")"
    cp "$file" "$output"
  done
  apply_template_variables "$destination"
}

ensure_wp_cli() {
  log "Ensuring WP-CLI is available in the wordpress container"
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c 'if ! command -v wp >/dev/null 2>&1; then curl -sS https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp && chmod +x /usr/local/bin/wp; fi'
}

ensure_composer() {
  log "Ensuring Composer is available in the wordpress container"
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "if ! command -v composer >/dev/null 2>&1; then php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\" && php composer-setup.php --install-dir=/usr/local/bin --filename=composer && rm composer-setup.php; fi"
}

ensure_unzip() {
  log "Ensuring unzip is available in the wordpress container"
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "if ! command -v unzip >/dev/null 2>&1; then apt-get update >/dev/null 2>&1 && DEBIAN_FRONTEND=noninteractive apt-get install -y unzip >/dev/null; fi"
}

ensure_node() {
  log "Ensuring Node.js 22.x LTS is available in the wordpress container"
  
  # Vérifier si Node.js est déjà installé avec la bonne version
  if ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "command -v node >/dev/null 2>&1"; then
    local node_version=$(${DOCKER_COMPOSE_CMD[@]} exec -T wordpress node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$node_version" = "22" ]; then
      log "Node.js $(${DOCKER_COMPOSE_CMD[@]} exec -T wordpress node --version) already installed"
      return
    fi
  fi
  
  log "Installing Node.js 22.x LTS via NodeSource"
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "
    apt-get update >/dev/null 2>&1 && \
    apt-get install -y ca-certificates curl gnupg >/dev/null 2>&1 && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main' | tee /etc/apt/sources.list.d/nodesource.list >/dev/null && \
    apt-get update >/dev/null 2>&1 && \
    apt-get install -y nodejs >/dev/null 2>&1
  " || echo "[setup-wordpress WARNING] Failed to install Node.js"
  
  log "Node.js $(${DOCKER_COMPOSE_CMD[@]} exec -T wordpress node --version) installed successfully"
}

configure_composer_allow_plugins() {
  log "Configuring Composer allow-plugins"
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "COMPOSER_ALLOW_SUPERUSER=1 composer config --global allow-plugins.composer/installers true"
}

wp_cli() {
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress wp --allow-root "$@"
}

ensure_containers_started() {
  log "Starting containers (if not already running)"
  ${DOCKER_COMPOSE_CMD[@]} up -d
}

wait_for_database() {
  log "Waiting for the database to be ready"
  local retries=30
  local wait_seconds=2
  for ((i=1; i<=retries; i++)); do
    if ${DOCKER_COMPOSE_CMD[@]} exec -T db mysqladmin ping -h"db" -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent >/dev/null 2>&1; then
      log "Database is ready"
      return 0
    fi
    sleep "$wait_seconds"
  done
  echo "[setup-wordpress ERROR] Database did not become ready in time." >&2
  exit 1
}

create_wp_config() {
  if ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress test -f wp-config.php; then
    log "wp-config.php already exists"
    
    # Vérifier si la configuration Redis existe déjà
    if ! ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress grep -q "WP_REDIS_HOST" wp-config.php 2>/dev/null; then
      log "Adding Redis configuration to existing wp-config.php"
      ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "
        # Trouver la ligne qui contient 'wp-settings.php' et insérer avant
        sed -i \"/require.*wp-settings.php/i\\\\
/* Redis Object Cache Configuration for LiteSpeed Cache */\\\\
define('WP_REDIS_HOST', 'redis');\\\\
define('WP_REDIS_PORT', 6379);\\\\
define('WP_REDIS_DATABASE', 0);\\\\
define('WP_REDIS_TIMEOUT', 1);\\\\
define('WP_REDIS_READ_TIMEOUT', 1);\\\\
define('WP_CACHE_KEY_SALT', '${WORDPRESS_DB_NAME}_');\\\\
define('WP_CACHE', true);\\\\
\" wp-config.php
      "
    else
      log "Redis configuration already exists in wp-config.php"
    fi
    return
  fi
  
  log "Generating wp-config.php using WP-CLI"
  wp_cli config create \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbhost="db:3306" \
    --dbprefix="${WORDPRESS_TABLE_PREFIX:-wp_}" \
    --skip-check
  
  # Ajouter la configuration Redis pour LiteSpeed Cache
  log "Adding Redis configuration to wp-config.php"
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "
    # Trouver la ligne qui contient 'wp-settings.php' et insérer avant
    sed -i \"/require.*wp-settings.php/i\\\\
/* Redis Object Cache Configuration for LiteSpeed Cache */\\\\
define('WP_REDIS_HOST', 'redis');\\\\
define('WP_REDIS_PORT', 6379);\\\\
define('WP_REDIS_DATABASE', 0);\\\\
define('WP_REDIS_TIMEOUT', 1);\\\\
define('WP_REDIS_READ_TIMEOUT', 1);\\\\
define('WP_CACHE_KEY_SALT', '${WORDPRESS_DB_NAME}_');\\\\
define('WP_CACHE', true);\\\\
\" wp-config.php
  "
}

install_core() {
  if wp_cli core is-installed >/dev/null 2>&1; then
    log "WordPress core already installed"
    return
  fi
  log "Installing WordPress core"
  wp_cli core install \
    --url="$WORDPRESS_URL" \
    --title="$WORDPRESS_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --skip-email
}

install_plugins() {
  local plugins=(
    advanced-custom-fields
    seo-by-rank-math
    litespeed-cache
    contact-form-7
    complianz-gdpr
  )

  log "Installing and activating plugins"
  for plugin in "${plugins[@]}"; do
    if wp_cli plugin is-active "$plugin" >/dev/null 2>&1; then
      log "Plugin '$plugin' already active"
      continue
    fi
    if wp_cli plugin is-installed "$plugin" >/dev/null 2>&1; then
      wp_cli plugin activate "$plugin" || echo "[setup-wordpress WARNING] Failed to activate plugin $plugin"
    else
      wp_cli plugin install "$plugin" --activate || echo "[setup-wordpress WARNING] Failed to install plugin $plugin"
    fi
  done
}

setup_redis_object_cache() {
  log "Setting up Redis object cache for LiteSpeed Cache"
  
  local object_cache_template="$PROJECT_ROOT/templates/object-cache.php"
  local object_cache_destination="$WORDPRESS_DIR/wp-content/object-cache.php"
  
  if [ -f "$object_cache_template" ]; then
    cp "$object_cache_template" "$object_cache_destination"
    log "Redis object cache drop-in installed"
  else
    log "Warning: object-cache.php template not found at $object_cache_template"
  fi
  
  # Vérifier que l'extension Redis PHP est bien disponible
  if ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress php -m | grep -q redis; then
    log "Redis PHP extension is installed and enabled"
  else
    echo "[setup-wordpress WARNING] Redis PHP extension not found. Redis object cache may not work."
  fi
}

install_themes() {
  local starter_relative="wp-content/themes/$STARTER_THEME_SLUG"
  local starter_container_dir="/var/www/html/wp-content/themes"
  local starter_container_path="$starter_container_dir/$STARTER_THEME_SLUG"
  local starter_host_path="$WORDPRESS_DIR/$starter_relative"

  if [ ! -d "$starter_host_path" ]; then
    log "Installing Timber starter theme via Composer"
    ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "cd '$starter_container_dir' && COMPOSER_ALLOW_SUPERUSER=1 composer create-project upstatement/timber-starter-theme '$STARTER_THEME_SLUG' --no-dev --prefer-dist --no-progress --no-interaction --ignore-platform-reqs" || {
      echo "[setup-wordpress WARNING] Failed to create Timber starter theme via Composer" >&2
    }
  elif [ -f "$starter_host_path/composer.json" ] && [ ! -d "$starter_host_path/vendor" ]; then
    log "Installing Composer dependencies for $STARTER_THEME_SLUG"
    ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "cd '$starter_container_path' && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --prefer-dist --no-progress --no-interaction --ignore-platform-reqs" || echo "[setup-wordpress WARNING] Composer install failed in $starter_container_path"
  else
    log "Timber starter theme already present"
  fi

  local themes_dir="$WORDPRESS_DIR/wp-content/themes"
  local destination="$themes_dir/$CUSTOM_THEME_SLUG"
  mkdir -p "$themes_dir"

  if [ -d "$destination" ]; then
    log "Custom theme '$CUSTOM_THEME_SLUG' already present, refreshing template variables"
    apply_template_variables "$destination"
  else
    log "Creating custom theme '$CUSTOM_THEME_SLUG' from template"
    copy_template_directory "$TEMPLATE_DIR" "$destination"
  fi

  log "Activating custom theme '$CUSTOM_THEME_SLUG'"
  wp_cli theme activate "$CUSTOM_THEME_SLUG" || echo "[setup-wordpress WARNING] Failed to activate custom theme $CUSTOM_THEME_SLUG"
}

maybe_install_node_dependencies() {
  local theme_path="$WORDPRESS_DIR/wp-content/themes/$CUSTOM_THEME_SLUG"
  local theme_container_path="/var/www/html/wp-content/themes/$CUSTOM_THEME_SLUG"
  
  if [ ! -d "$theme_path" ]; then
    return
  fi

  if [ ! -f "$theme_path/package.json" ]; then
    log "No package.json found in custom theme, skipping npm install"
    return
  fi

  log "Installing npm dependencies for custom theme in container"
  ${DOCKER_COMPOSE_CMD[@]} exec -T wordpress bash -c "cd '$theme_container_path' && npm install" || echo "[setup-wordpress WARNING] npm install failed inside container for $theme_container_path"
}

main() {
  if [ ! -f .env ]; then
    echo "[setup-wordpress ERROR] No .env file found at $PROJECT_ROOT/.env" >&2
    exit 1
  fi

  set -a
  # shellcheck disable=SC1091
  source .env
  set +a

  require_env_var WORDPRESS_DB_USER
  require_env_var WORDPRESS_DB_PASSWORD
  require_env_var WORDPRESS_DB_NAME
  require_env_var MYSQL_ROOT_PASSWORD
  require_env_var WORDPRESS_URL
  require_env_var WORDPRESS_TITLE
  require_env_var WORDPRESS_ADMIN_USER
  require_env_var WORDPRESS_ADMIN_PASSWORD
  require_env_var WORDPRESS_ADMIN_EMAIL
  require_env_var CUSTOM_THEME_NAME

  WORDPRESS_HOST_PORT="${WORDPRESS_HOST_PORT:-8080}"
  STARTER_THEME_SLUG="timber-starter-theme"
  CUSTOM_THEME_SLUG="${CUSTOM_THEME_SLUG:-$(slugify "$CUSTOM_THEME_NAME")}" 
  TEMPLATE_DIR="$PROJECT_ROOT/scripts/custom-theme"

  mkdir -p "$WORDPRESS_DIR"

  local compose_binary
  compose_binary=$(pick_compose)
  IFS=' ' read -r -a DOCKER_COMPOSE_CMD <<< "$compose_binary"

  ensure_containers_started
  wait_for_database
  ensure_wp_cli
  ensure_composer
  ensure_unzip
  ensure_node
  configure_composer_allow_plugins
  create_wp_config
  install_core
  install_plugins
  install_themes
  maybe_install_node_dependencies

  log "Setup complete. You can now develop on $WORDPRESS_URL"
}

main "$@"
