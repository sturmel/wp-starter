# WordPress Starter Kit avec Docker, Timber, Webpack, Tailwind CSS v4, GSAP et Outils Modernes

Ce projet est un kit de démarrage professionnel pour développer des sites WordPress modernes et performants en utilisant Docker. Il fournit un environnement de développement local complet, préconfiguré avec WordPress, MySQL, Redis, WP-CLI, Composer, Node.js (via NVM), et une chaîne de build moderne basée sur **Webpack 5**. Le projet met en place automatiquement un thème enfant basé sur `timber-starter-theme` avec une architecture frontend moderne incluant Tailwind CSS v4, GSAP, BrowserSync, et des outils d'optimisation avancés.

## 🚀 Fonctionnalités Principales

### **Environnement de Développement Dockerisé**
*   **Services Complets** : WordPress, MySQL, et Redis gérés via `docker compose`
*   **Installation Automatisée** : WordPress configuré automatiquement au premier lancement
*   **Contenu Persistant** : Le dossier `wp-content` est mappé pour conserver vos données entre les sessions

### **Thème Enfant Timber Intelligent**
*   **Création Automatique** : Génération d'un thème enfant basé sur `timber-starter-theme`
*   **Personnalisation** : Nom du thème configurable via `CUSTOM_THEME_NAME`
*   **Dépendances PHP** : `composer.json` copié et dépendances installées automatiquement
*   **Architecture Moderne** : Séparation logique avec dossiers `inc/`, `views/`, `assets/`

### **🔧 Chaîne de Build Webpack 5 Complète**
*   **Configuration Avancée** : Webpack configuré pour développement et production
*   **Build Intelligente** : 
    *   Mode développement : Builds dans `dev_build/` avec source maps
    *   Mode production : Builds optimisées dans `dist/` avec minification
*   **Hot Reload** : Compilation automatique en mode watch
*   **Optimisation Assets** : Clean automatique des builds précédentes

### **🎨 Frontend Moderne et Optimisé**
*   **Tailwind CSS v4** : Framework utility-first avec nouvelle architecture
    *   Support complet des directives `@import "tailwindcss"`
    *   Configuration `@content` pour la détection automatique
    *   Layers personnalisables (`@layer base`, `@layer components`, `@layer utilities`)
    *   Variables personnalisées avec `@theme`
*   **JavaScript Moderne** :
    *   Support ES6+ avec Babel
    *   Bundling intelligent avec Webpack
    *   GSAP inclus pour les animations
    *   Modules ES6 supportés
*   **Traitement CSS Avancé** :
    *   PostCSS avec autoprefixer
    *   Import CSS avec `postcss-import`
    *   Extraction CSS avec `MiniCssExtractPlugin`

### **⚡ Outils de Développement Intégrés**
*   **BrowserSync** : 
    *   Synchronisation temps réel sur port 3000
    *   Injection CSS à chaud
    *   Interface de contrôle sur port 3001
    *   Proxy automatique vers WordPress (port 8080)
*   **Scripts NPM Optimisés** :
    *   `npm run dev` : Mode développement avec watch et BrowserSync
    *   `npm run build` : Build de production avec minification
*   **Optimisation Production** :
    *   Minification JavaScript avec Terser
    *   Compression CSS optimisée
    *   Cache busting automatique avec `filemtime()`

### **🛠️ Stack Technique Complet**
*   **Backend** : 
    *   WP-CLI intégré dans le conteneur
    *   Composer pour la gestion des dépendances PHP
    *   Node.js 22.10.0 via NVM
*   **Performance** :
    *   Redis pour le cache d'objets
    *   Optimisations WordPress (emojis, REST API, etc.)
    *   Désactivation sélective des styles inutiles
*   **Sécurité** :
    *   Configuration sécurisée par défaut
    *   Suppression des en-têtes WordPress sensibles
    *   Protection contre l'édition de fichiers
*   **Communication** :
    *   msmtp pour l'envoi d'e-mails via SMTP
    *   Configuration Mailtrap recommandée pour le développement

### **🔒 Gestion d'Environnements**
*   **Mode Développement** (`WORDPRESS_ENV=development`) :
    *   Modifications de fichiers autorisées
    *   Erreurs PHP affichées
    *   Assets non minifiés avec source maps
    *   BrowserSync activé
*   **Mode Production** (`WORDPRESS_ENV=production`) :
    *   Modifications de fichiers bloquées
    *   Assets minifiés et optimisés
    *   Sécurité renforcée
    *   Performance maximisée

## 📋 Prérequis

*   [Docker](https://docs.docker.com/get-docker/)
*   [Docker Compose](https://docs.docker.com/compose/install/) (généralement inclus avec Docker Desktop)
*   Un navigateur moderne pour tester les fonctionnalités frontend

## 🚀 Démarrage Rapide

1.  **Cloner le dépôt** :
    ```bash
    git clone <votre-url-de-repo>
    cd <nom-du-dossier-du-projet>
    ```

2.  **Configurer l'environnement** :
    Copiez le fichier d'exemple `.env.example` vers `.env` :
    ```bash
    cp .env.example .env
    ```
    Modifiez le fichier `.env` avec vos propres informations. **Points clés à configurer** :
    *   `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`, `MYSQL_ROOT_PASSWORD` : Identifiants de la base de données
    *   `WORDPRESS_URL` : URL complète de votre site WordPress local (ex: `http://localhost:8080`)
    *   `WORDPRESS_HOST_PORT` : Port sur votre machine hôte (doit correspondre à `WORDPRESS_URL`)
    *   `CUSTOM_THEME_NAME` : Nom (slug) de votre thème enfant (ex: `mon-super-theme`)
    *   `WORDPRESS_ENV` : `development` pour le développement, `production` pour la production
    *   Variables SMTP : `MSMTP_HOST`, `MSMTP_PORT`, etc. (Mailtrap recommandé pour le développement)

3.  **Lancer les conteneurs Docker** :
    ```bash
    docker compose up -d --build
    ```
    L'option `--build` est recommandée au premier lancement pour construire les images avec toutes les dépendances.

4.  **Installation Automatique** :
    Le script `custom-entrypoint.sh` va automatiquement :
    *   Attendre que MySQL soit prêt
    *   Installer WordPress avec vos paramètres
    *   Configurer `wp-config.php` et les clés de sécurité
    *   Cloner et configurer `timber-starter-theme`
    *   **Créer le thème enfant avec l'architecture Webpack** :
        *   Génération de `package.json` avec toutes les dépendances
        *   Installation automatique des packages npm
        *   Configuration Webpack complète (`webpack.config.js`)
        *   Fichiers PostCSS et BrowserSync
        *   Structure d'assets moderne (`assets/css/main.css`, `assets/js/scripts.js`)
        *   Build initiale des assets
    *   Activer le thème enfant
    *   Installer et activer les plugins essentiels
    *   Configurer Redis et msmtp

5.  **Accéder à WordPress** :
    *   **Site principal** : `http://localhost:8080` (ou votre `WORDPRESS_URL`)
    *   **BrowserSync** : `http://localhost:3000` (avec hot reload automatique)
    *   **Interface BrowserSync** : `http://localhost:3001`
    *   **Admin WordPress** : `http://localhost:8080/wp-admin`

6.  **Démarrer le développement frontend** :
    ```bash
    # Pour l'instant, naviguer vers votre thème directement sur votre machine hôte
    cd wp-content/themes/[VOTRE_THEME_NAME]
    
    # Installer les dépendances npm si nécessaire
    npm install
    
    # Lancer le mode développement avec watch + BrowserSync
    npm run dev
    ```
    
    > **Note** : Pour l'instant, il est recommandé de lancer les commandes npm directement sur votre machine hôte plutôt que dans le conteneur Docker. Assurez-vous d'avoir Node.js installé localement.

## 📁 Structure du Projet

```
.
├── docker-compose.yml            # Configuration des services (WordPress, MySQL, Redis)
├── .env.example                  # Template de configuration d'environnement
├── .env                         # Configuration d'environnement (ignoré par Git)
├── LICENSE                      # Licence du projet
├── README.md                    # Documentation complète
├── docker/
│   ├── Dockerfile--wordpress    # Image WordPress personnalisée avec tous les outils
│   ├── custom-entrypoint.sh     # Script d'initialisation principal
│   └── scripts/                 # Scripts modulaires d'initialisation
│       ├── init-variables.sh    # Initialisation des variables
│       ├── check-dependencies.sh # Vérification des dépendances
│       ├── setup-wordpress-core.sh # Installation WordPress
│       ├── manage-themes.sh     # Gestion des thèmes + build Webpack
│       ├── manage-plugins.sh    # Installation des plugins
│       ├── configure-redis.sh   # Configuration Redis
│       ├── configure-msmtp.sh   # Configuration email
│       └── finalize-config.sh   # Finalisation de la configuration
└── wp-content/                  # Contenu WordPress persistant
    ├── themes/
    │   ├── timber-starter-theme/ # Thème parent Timber officiel
    │   └── [CUSTOM_THEME_NAME]/  # Votre thème enfant avec architecture Webpack
    │       ├── style.css         # Informations du thème enfant
    │       ├── functions.php     # Fonctions PHP et enqueue des assets
    │       ├── package.json      # Dépendances npm et scripts de build
    │       ├── webpack.config.js # Configuration Webpack complète
    │       ├── postcss.config.js # Configuration PostCSS
    │       ├── browsersync.config.js # Configuration BrowserSync
    │       ├── .gitignore        # Exclusions Git (node_modules, dist, etc.)
    │       ├── composer.json     # Dépendances PHP (copié du parent)
    │       ├── vendor/           # Dépendances PHP (Timber, etc.)
    │       ├── node_modules/     # Dépendances npm (généré automatiquement)
    │       ├── dist/             # Assets de production (minifiés)
    │       │   ├── main.min.js   # JavaScript optimisé
    │       │   └── styles.min.css # CSS optimisé
    │       ├── dev_build/        # Assets de développement
    │       │   ├── main.js       # JavaScript avec source maps
    │       │   └── styles.css    # CSS non minifié
    │       ├── assets/           # Sources des assets
    │       │   ├── css/
    │       │   │   └── main.css  # CSS principal avec Tailwind v4
    │       │   └── js/
    │       │       └── scripts.js # JavaScript principal (ES6+)
    │       ├── inc/              # Fichiers PHP modulaires
    │       │   ├── performance.php # Optimisations WordPress
    │       │   └── security.php  # Sécurisations WordPress
    │       └── views/            # Templates Twig (à créer selon besoins)
    ├── plugins/                  # Plugins WordPress
    │   ├── advanced-custom-fields/
    │   ├── wordpress-seo/
    │   ├── litespeed-cache/
    │   ├── contact-form-7/
    │   └── redis-cache/
    └── uploads/                  # Fichiers uploadés
```

## ⚙️ Variables d'Environnement

Configurez ces variables dans votre fichier `.env` :

### **Configuration Base de Données**
*   `WORDPRESS_DB_HOST` : Hôte de la base de données (par défaut `db`)
*   `WORDPRESS_DB_USER` : Utilisateur de la base de données
*   `WORDPRESS_DB_PASSWORD` : Mot de passe de l'utilisateur
*   `WORDPRESS_DB_NAME` : Nom de la base de données
*   `MYSQL_ROOT_PASSWORD` : Mot de passe root pour MySQL

### **Configuration Site WordPress**
*   `WORDPRESS_URL` : URL complète du site (ex: `http://localhost:8080`)
*   `WORDPRESS_TITLE` : Titre de votre site WordPress
*   `WORDPRESS_ADMIN_USER` : Nom d'utilisateur administrateur
*   `WORDPRESS_ADMIN_PASSWORD` : Mot de passe administrateur
*   `WORDPRESS_ADMIN_EMAIL` : Email de l'administrateur
*   `WORDPRESS_TABLE_PREFIX` : Préfixe des tables (par défaut `wp_`)
*   `CUSTOM_THEME_NAME` : Slug de votre thème enfant (ex: `mon-theme`)

### **Configuration Environnement** ⚡
*   `WORDPRESS_ENV` : 
    *   `development` : Mode développement avec BrowserSync, assets non minifiés, erreurs affichées
    *   `production` : Mode production avec assets optimisés, sécurité renforcée

### **Configuration Docker**
*   `WORDPRESS_HOST_PORT` : Port sur la machine hôte (ex: `8080`)

### **Configuration Redis** (Cache d'objets)
*   `WORDPRESS_REDIS_HOST` : Hôte Redis (par défaut `redis`)
*   `WORDPRESS_REDIS_PORT` : Port Redis (par défaut `6379`)

### **Configuration SMTP** (Emails via msmtp)
*   `MSMTP_HOST` : Serveur SMTP (ex: `sandbox.smtp.mailtrap.io`)
*   `MSMTP_PORT` : Port SMTP (ex: `587`)
*   `MSMTP_FROM` : Adresse email d'expédition
*   `MSMTP_AUTH` : Authentification (`on` ou `off`)
*   `MSMTP_USER` : Nom d'utilisateur SMTP
*   `MSMTP_PASSWORD` : Mot de passe SMTP
*   `MSMTP_TLS` : Utiliser TLS (`on` ou `off`)
*   `MSMTP_TLS_STARTTLS` : Utiliser STARTTLS (`on` ou `off`)
*   `MSMTP_LOGFILE` : Fichier de log msmtp (ex: `/tmp/msmtp.log`)

## 🛠️ Guide de Développement

### **Accéder au Conteneur WordPress**

```bash
# Accéder au shell du conteneur
docker compose exec wordpress bash

# Vérifier l'environnement Node.js
node --version  # Devrait afficher v22.10.0
npm --version   # Devrait afficher la version npm correspondante
```

### **🔧 Développement Frontend avec Webpack**

#### **Architecture des Assets**

Le système de build Webpack est configuré pour gérer intelligemment les environnements :

```bash
# Naviguer vers votre thème
cd wp-content/themes/[CUSTOM_THEME_NAME]

# Structure des assets
assets/css/main.css          # Source Tailwind CSS v4
assets/js/scripts.js         # Source JavaScript ES6+
dev_build/                   # Build de développement (non minifié)
dist/                        # Build de production (optimisé)
```

#### **Scripts NPM Disponibles**

```bash
# Mode développement avec watch + BrowserSync
npm run dev
# - Compilation automatique en mode watch
# - BrowserSync sur localhost:3000
# - Source maps activées
# - Assets dans dev_build/

# Build de production
npm run build  
# - Minification avec Terser
# - Optimisation CSS
# - Assets dans dist/
# - Cache busting automatique
```

#### **Configuration Tailwind CSS v4**

Le fichier `assets/css/main.css` utilise la nouvelle syntaxe Tailwind v4 :

```css
/* Import Tailwind's base, components, and utilities for v4 */
@import "tailwindcss";

/* Explicitly define content paths for Tailwind v4 */
@content '../../views/**/*.twig';
@content '../../*.php';
@content '../js/**/*.js';

/* Custom layers */
@layer base {
  /* Vos styles de base */
}

@layer components {
  /* Vos composants réutilisables */
}

@layer utilities {
  /* Vos utilitaires personnalisés */
}

/* Custom theme variables for Tailwind v4 */
@theme {
  /* Variables CSS personnalisées */
}
```

#### **JavaScript Moderne avec ES6+**

Le fichier `assets/js/scripts.js` supporte les modules ES6 et les imports :

```javascript
import { gsap } from 'gsap';

// Votre code JavaScript moderne
addEventListener('DOMContentLoaded', function() {
   console.log('🔧 Webpack entry file loaded');
   
   // Utilisation de GSAP
   gsap.from('.my-element', {duration: 2, y: 50, opacity: 0});
});
```

#### **BrowserSync et Hot Reload**

En mode développement, BrowserSync est automatiquement configuré :
- **Proxy principal** : `localhost:3000` (avec hot reload)
- **Interface de contrôle** : `localhost:3001`
- **Synchronisation** : CSS, PHP, Twig, JS
- **Injection CSS** : Changements appliqués sans rechargement de page

### **🔨 Gestion des Dépendances**

#### **Dépendances PHP avec Composer**

```bash
# Dans le dossier de votre thème
composer require mon-paquet/librairie    # Ajouter une dépendance
composer update                         # Mettre à jour
composer install                        # Installer (si vendor/ manquant)
```

#### **Dépendances JavaScript avec npm**

```bash
# Ajouter des dépendances
npm install lodash --save               # Dépendance de production
npm install @types/node --save-dev      # Dépendance de développement

# Mettre à jour les dépendances
npm update

# Auditer la sécurité
npm audit --fix
```

### **📝 Utilisation de WP-CLI**

WP-CLI est préinstallé et accessible globalement. **Important** : Utilisez toujours `--allow-root` :

```bash
# Exemples courants
wp plugin list --allow-root
wp plugin install jetpack --activate --allow-root
wp theme list --allow-root
wp cache flush --allow-root
wp db cli --allow-root

# Gestion des utilisateurs
wp user list --allow-root
wp user create john john@example.com --role=editor --allow-root

# Import/Export de contenu
wp db export backup.sql --allow-root
wp db import backup.sql --allow-root
```

### **📊 Monitoring et Logs**

```bash
# Logs des services Docker
docker compose logs wordpress           # Logs WordPress
docker compose logs -f wordpress       # Suivre les logs en temps réel
docker compose logs db                 # Logs MySQL
docker compose logs redis              # Logs Redis

# Status des conteneurs
docker compose ps

# Redémarrer un service
docker compose restart wordpress
```

## 🏗️ Architecture du Thème Enfant

### **Structure et Organisation**

Le thème enfant généré automatiquement suit une architecture moderne et modulaire :

```
[CUSTOM_THEME_NAME]/
├── style.css                    # Informations du thème (nom, version, parent)
├── functions.php                # Point d'entrée principal + enqueue des assets
├── .gitignore                   # Exclusions Git (node_modules, dist, etc.)
│
├── inc/                         # Modules PHP organisés
│   ├── performance.php          # Optimisations WordPress
│   └── security.php             # Sécurisations WordPress
│
├── assets/                      # Sources des assets (non compilés)
│   ├── css/
│   │   └── main.css            # CSS principal avec Tailwind v4
│   └── js/
│       └── scripts.js          # JavaScript ES6+ principal
│
├── dev_build/                   # Assets de développement (généré)
│   ├── main.js                 # JavaScript avec source maps
│   └── styles.css              # CSS non minifié avec source maps
│
├── dist/                        # Assets de production (généré)
│   ├── main.min.js             # JavaScript optimisé et minifié
│   └── styles.min.css          # CSS optimisé et minifié
│
├── views/                       # Templates Twig (à créer selon besoins)
│   ├── base.twig               # Template de base
│   ├── index.twig              # Page d'accueil
│   └── single.twig             # Article/page individuelle
│
├── node_modules/                # Dépendances npm (auto-généré)
├── vendor/                      # Dépendances PHP Composer (auto-généré)
│
└── Configuration Build
    ├── package.json             # Dépendances npm + scripts
    ├── webpack.config.js        # Configuration Webpack complète
    ├── postcss.config.js        # Configuration PostCSS
    ├── browsersync.config.js    # Configuration BrowserSync
    └── composer.json            # Dépendances PHP (copié du parent)
```

### **🎨 Système d'Assets Intelligent**

#### **Enqueue Automatique selon l'Environnement**

Le `functions.php` détecte automatiquement l'environnement via `WORDPRESS_ENV` :

```php
$wordpress_env = getenv('WORDPRESS_ENV');

if ($wordpress_env === 'development') {
    // Assets de développement (non minifiés, avec source maps)
    $css_file = '/dev_build/styles.css';
    $js_file = '/dev_build/main.js';
} else {
    // Assets de production (minifiés, optimisés)
    $css_file = '/dist/styles.min.css';
    $js_file = '/dist/main.min.js';
}
```

#### **Cache Busting Automatique**

Les assets utilisent `filemtime()` pour un cache busting automatique :

```php
wp_enqueue_style(
    'tailwind-style',
    get_stylesheet_directory_uri() . $css_file,
    array('child-style'),
    filemtime(get_stylesheet_directory() . $css_file)
);
```

#### **Support ES6 Modules**

Les scripts JavaScript sont chargés comme modules ES6 :

```php
function add_type_attribute_to_script($tag, $handle, $src) {
    if ('child-scripts' === $handle) {
        $tag = '<script type="module" src="' . esc_url($src) . '" id="' . $handle . '-js"></script>';
    }
    return $tag;
}
```

### **⚡ Optimisations WordPress Intégrées**

#### **Performance (`inc/performance.php`)**
- Suppression des emojis WordPress
- Désactivation des styles de blocs inutiles
- Optimisation des en-têtes HTTP
- Suppression des générateurs de version

#### **Sécurité (`inc/security.php`)**
- Désactivation de XML-RPC
- Suppression des informations de version
- Protection contre l'édition de fichiers
- Nettoyage des en-têtes sensibles

### **🔧 Configuration Webpack Avancée**

#### **Entrées Multiples**
```javascript
entry: {
  main: './assets/js/scripts.js',     // JavaScript principal
  styles: './assets/css/main.css'     // CSS principal
}
```

#### **Optimisation Conditionnelle**
- **Développement** : Source maps, builds rapides, BrowserSync
- **Production** : Minification Terser, optimisation CSS, cache busting

#### **Loaders Configurés**
- **Babel** : Transpilation ES6+ vers ES5
- **PostCSS** : Traitement CSS avec Tailwind v4 et autoprefixer
- **CSS Loader** : Gestion des imports et modules CSS

### **🎯 Points d'Extension Recommandés**

#### **Ajout de Templates Twig**
```bash
# Créer vos templates dans views/
mkdir -p views/components
touch views/components/header.twig
touch views/components/footer.twig
```

#### **Ajout de Dépendances**
```bash
# JavaScript
npm install swiper --save
npm install @types/swiper --save-dev

# PHP
composer require twig/twig
```

#### **Personnalisation Tailwind**
Créez un `tailwind.config.js` pour des personnalisations avancées :
```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#your-color'
      }
    }
  }
}
```

## 📧 Configuration des E-mails (msmtp)

Le conteneur WordPress utilise `msmtp` pour envoyer des e-mails via un serveur SMTP externe, essentiel pour tester les fonctionnalités email en développement.

### **Configuration Recommandée : Mailtrap**

Pour le développement, [Mailtrap.io](https://mailtrap.io) est idéal car il capture tous les e-mails sans les délivrer :

```env
# Dans votre .env
MSMTP_HOST=sandbox.smtp.mailtrap.io
MSMTP_PORT=587
MSMTP_FROM=noreply@votre-site.local
MSMTP_AUTH=on
MSMTP_USER=votre_username_mailtrap
MSMTP_PASSWORD=votre_password_mailtrap
MSMTP_TLS=off
MSMTP_TLS_STARTTLS=on
MSMTP_LOGFILE=/tmp/msmtp.log
```

Le fichier `/etc/msmtprc` est généré automatiquement au démarrage du conteneur.

## 🚨 Dépannage

### **Problèmes Courants**

#### **Permissions sur `wp-content`**
```bash
# Vérifier les permissions
ls -la wp-content/

# Corriger si nécessaire (Linux/Mac)
sudo chown -R $USER:$USER wp-content/
chmod -R 755 wp-content/
```

#### **Le site ne se charge pas**
```bash
# Vérifier les logs
docker compose logs wordpress
docker compose logs db

# Vérifier la configuration
grep WORDPRESS_URL .env
grep WORDPRESS_HOST_PORT .env
```

#### **Erreurs npm/Webpack**
```bash
# Accéder au conteneur
docker compose exec wordpress bash
cd wp-content/themes/[THEME_NAME]

# Vérifier Node.js
node --version
npm --version

# Nettoyer et réinstaller
rm -rf node_modules package-lock.json
npm install

# Tester la build
npm run build
```

#### **BrowserSync ne fonctionne pas**
```bash
# Vérifier que le mode dev est actif
npm run dev

# Vérifier les ports
netstat -tlnp | grep :3000
netstat -tlnp | grep :3001

# Accéder via les bonnes URLs
# Site principal: http://localhost:8080
# BrowserSync: http://localhost:3000
# Interface BrowserSync: http://localhost:3001
```

#### **Assets CSS/JS ne se chargent pas**
```bash
# Vérifier l'environnement WordPress
echo $WORDPRESS_ENV

# En développement, vérifier dev_build/
ls -la dev_build/

# En production, vérifier dist/
ls -la dist/

# Forcer une rebuild
npm run build
```

#### **Erreurs WP-CLI**
```bash
# Toujours utiliser --allow-root
wp plugin list --allow-root

# Vérifier les permissions de fichiers
wp config path --allow-root
```

#### **MySQL indisponible**
```bash
# Vérifier le status des conteneurs
docker compose ps

# Redémarrer les services
docker compose down
docker compose up -d

# Vérifier les logs MySQL
docker compose logs db
```

#### **Changements Tailwind non reflétés**
```bash
# S'assurer que npm run dev est actif
ps aux | grep webpack

# Vérifier le fichier source
cat assets/css/main.css

# Vérifier la build
cat dev_build/styles.css  # En développement
cat dist/styles.min.css   # En production

# Nettoyer le cache navigateur
# Ctrl+F5 ou Cmd+Shift+R
```

### **Commandes de Diagnostic**

```bash
# Status complet des services
docker compose ps -a

# Logs détaillés
docker compose logs --tail=100 wordpress

# Ressources système
docker stats

# Nettoyage complet (⚠️ supprime les données)
docker compose down -v
docker system prune -af
```

## 🐳 Commandes Docker Compose Utiles

### **Gestion des Services**
```bash
# Démarrer en arrière-plan
docker compose up -d

# Démarrer avec rebuild forcé
docker compose up -d --build

# Arrêter les services
docker compose down

# Arrêter et supprimer les volumes (⚠️ supprime la base de données !)
docker compose down -v

# Redémarrer un service spécifique
docker compose restart wordpress
```

### **Monitoring et Logs**
```bash
# Status des conteneurs
docker compose ps

# Logs en temps réel
docker compose logs -f wordpress
docker compose logs -f db
docker compose logs -f redis

# Logs des dernières 100 lignes
docker compose logs --tail=100 wordpress

# Statistiques d'utilisation
docker stats
```

### **Maintenance et Nettoyage**
```bash
# Reconstruire les images
docker compose build

# Nettoyer les images inutilisées
docker image prune -f

# Nettoyage complet du système Docker (⚠️ supprime tout)
docker system prune -af

# Sauvegarder la base de données
docker compose exec db mysqldump -u root -p[MYSQL_ROOT_PASSWORD] [WORDPRESS_DB_NAME] > backup.sql

# Restaurer la base de données
docker compose exec -T db mysql -u root -p[MYSQL_ROOT_PASSWORD] [WORDPRESS_DB_NAME] < backup.sql
```

## 🚀 Workflow de Développement Recommandé

### **Démarrage d'un Nouveau Projet**

1. **Configuration initiale**
```bash
cp .env.example .env
# Éditer .env avec vos paramètres
docker compose up -d --build
```

2. **Développement frontend**
```bash
docker compose exec wordpress bash
cd wp-content/themes/[THEME_NAME]
npm run dev  # Lance watch + BrowserSync
```

3. **Accéder aux interfaces**
- Site WordPress : `http://localhost:8080`
- BrowserSync : `http://localhost:3000`
- Admin WordPress : `http://localhost:8080/wp-admin`

### **Workflow Quotidien**

```bash
# Démarrer la journée
docker compose up -d
docker compose exec wordpress bash
cd wp-content/themes/[THEME_NAME]
npm run dev

# Développer dans votre éditeur favori
# Les changements CSS/JS sont automatiquement recompilés
# BrowserSync recharge automatiquement le navigateur

# Arrêter en fin de journée
# Ctrl+C pour arrêter npm run dev
docker compose down
```

### **Déploiement en Production**

```bash
# Build de production
cd wp-content/themes/[THEME_NAME]
npm run build

# Vérifier les assets optimisés
ls -la dist/

# Les assets minifiés sont automatiquement utilisés
# quand WORDPRESS_ENV=production
```

## 🤝 Contribuer

Les suggestions et contributions sont les bienvenues ! 

### **Comment Contribuer**
1. Forkez le projet
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Poussez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### **Signaler des Bugs**
Utilisez les [Issues GitHub](https://github.com/votre-repo/issues) en incluant :
- Version de Docker/Docker Compose
- OS utilisé
- Configuration `.env` (sans mots de passe)
- Logs d'erreur complets

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👏 Crédits

- **Concept initial** : [Lugh Web](https://lugh-web.fr)
- **Timber** : [Timber Library](https://timber.github.io/docs/)
- **Tailwind CSS** : [Tailwind CSS](https://tailwindcss.com/)
- **WordPress** : [WordPress.org](https://wordpress.org/)

---

**📖 Documentation Complète** | **🐛 Signaler un Bug** | **💡 Demander une Fonctionnalité**

*Développé avec ❤️ pour la communauté WordPress*
