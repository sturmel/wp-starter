# WordPress Starter Kit avec Docker, Timber, Webpack 5, Tailwind CSS v4, GSAP et Architecture Moderne

Ce projet est un **kit de démarrage professionnel** pour développer des sites WordPress modernes et performants en utilisant Docker. Il fournit un environnement de développement local complet, préconfiguré avec WordPress, MySQL, Redis, WP-CLI, Composer, Node.js (via NVM), et une chaîne de build moderne basée sur **Webpack 5**.

Le système génère automatiquement un **thème enfant intelligent** basé sur `timber-starter-theme` avec une architecture frontend complète incluant **Tailwind CSS v4**, **GSAP**, **BrowserSync**, et des outils d'optimisation avancés. Le thème suit les meilleures pratiques de développement moderne avec une séparation claire entre le backend PHP/Twig et le frontend JavaScript/CSS.

## 🚀 Fonctionnalités Principales

### **🐳 Environnement de Développement Dockerisé**
*   **Services Complets** : WordPress, MySQL, et Redis gérés via `docker compose`
*   **Installation Automatisée** : WordPress configuré automatiquement au premier lancement
*   **Support Reverse Proxy Natif** : Correction automatique de la détection SSL (`HTTPS`) lorsque le site est derrière un reverse proxy, garantissant que les URLs et les assets sont servis avec le bon protocole.
*   **Contenu Persistant** : Le dossier `wp-content` est mappé pour conserver vos données entre les sessions
*   **Outils Préinstallés** : WP-CLI, Composer, Node.js 22.10.0 via NVM, Git, msmtp

### **🎨 Thème Enfant Timber Intelligent avec Architecture Moderne**
*   **Génération Automatique** : Création complète d'un thème enfant basé sur `timber-starter-theme`
*   **Personnalisation** : Nom du thème configurable via `CUSTOM_THEME_NAME`
*   **Dépendances Gérées** : 
    *   `composer.json` copié et dépendances PHP installées automatiquement
    *   `package.json` généré avec toutes les dépendances npm modernes
    *   Installation automatique des packages npm lors de la première initialisation
*   **Architecture Modulaire** : 
    *   `inc/` : Modules PHP (sécurité, performance)
    *   `views/` : Templates Twig organisés
    *   `assets/` : Sources CSS/JS non compilées
    *   `dist/` : Assets de production optimisés
    *   `dev_build/` : Assets de développement avec source maps

### **⚡ Chaîne de Build Webpack 5 Complète**
*   **Configuration Avancée** : Webpack configuré pour développement et production
*   **Build Intelligente selon l'Environnement** : 
    *   **Mode développement** : Builds dans `dev_build/` avec source maps et hot reload
    *   **Mode production** : Builds hautement optimisées dans `dist/` avec minification agressive, tree-shaking et optimisations avancées.
*   **Hot Reload** : Compilation automatique en mode watch avec BrowserSync
*   **Optimisation Poussée des Assets** : 
    *   **JavaScript** : Minification avancée avec `TerserPlugin` (suppression des `console.log`, code mort) et support ES6+.
    *   **CSS** : Optimisation extrême avec `CssMinimizerPlugin` et PostCSS.
    *   **Tree Shaking** : Suppression automatique du code JavaScript non utilisé en production.
    *   Clean automatique des builds précédentes

### **🎯 Frontend Moderne et Optimisé**
*   **Tailwind CSS v4** : Framework utility-first avec la nouvelle architecture
    *   Support complet des directives `@import "tailwindcss"`
    *   Configuration `@content` pour la détection automatique des classes
    *   Layers personnalisables (`@layer base`, `@layer components`, `@layer utilities`)
    *   Variables personnalisées avec `@theme`
    *   PostCSS intégré avec autoprefixer
*   **JavaScript ES6+ Moderne** :
    *   Support complet ES6+ avec Babel et présets modernes
    *   Modules ES6 supportés nativement
    *   GSAP inclus pour les animations fluides
    *   Bundling intelligent avec code splitting potentiel
*   **Système de Templating Twig** :
    *   Séparation logique entre PHP et templates
    *   Architecture MVC avec Timber
    *   Réutilisabilité des composants
    *   Sécurité accrue avec échappement automatique

### **🔧 Outils de Développement Intégrés**
*   **BrowserSync Pro** : 
    *   Synchronisation temps réel sur port 3000
    *   Injection CSS à chaud sans rechargement
    *   Interface de contrôle avancée sur port 3001
    *   Proxy automatique vers WordPress (port configuré)
    *   Synchronisation multi-dispositifs
*   **Scripts NPM Optimisés** :
    *   `npm run dev` : Mode développement avec watch et BrowserSync
    *   `npm run build` : Build de production avec minification complète
*   **Optimisation Production Avancée** :
    *   Minification JavaScript avec Terser et optimisations ES6
    *   Compression CSS optimisée avec suppression des doublons
    *   Tree shaking automatique pour réduire la taille des bundles
    *   Cache busting automatique avec versions basées sur `filemtime()`

### **🛠️ Stack Technique Complet**
*   **Backend WordPress Optimisé** : 
    *   WP-CLI intégré dans le conteneur pour administration
    *   Composer pour la gestion des dépendances PHP
    *   Node.js 22.10.0 via NVM pour un environnement moderne
    *   Timber library pour l'architecture MVC
*   **Performance et Cache** :
    *   Redis pour le cache d'objets WordPress
    *   Optimisations WordPress (désactivation emojis, REST API, etc.)
    *   Désactivation sélective des styles de blocs WordPress
    *   Préchargement et optimisation des requêtes
*   **Sécurité Renforcée** :
    *   Configuration sécurisée par défaut
    *   Suppression des en-têtes WordPress sensibles
    *   Protection contre l'édition de fichiers en production
    *   Désactivation XML-RPC et autres vecteurs d'attaque
    *   Plugins de sécurité préinstallés : Wordfence, Complianz GDPR
*   **Communication Email** :
    *   msmtp pour l'envoi d'e-mails via SMTP externe
    *   Configuration Mailtrap recommandée pour le développement
    *   Support TLS/STARTTLS pour la sécurité

### **🌍 Gestion d'Environnements Intelligente**
*   **Mode Développement** (`WORDPRESS_ENV=development`) :
    *   Modifications de fichiers autorisées
    *   Contrôle avancé des avertissements PHP via `WORDPRESS_SHOW_WARNINGS`
    *   Assets non minifiés avec source maps détaillées
    *   BrowserSync activé avec hot reload
    *   Plugins de développement activés
*   **Mode Production** (`WORDPRESS_ENV=production`) :
    *   Modifications de fichiers bloquées pour la sécurité
    *   Assets minifiés et optimisés pour la performance
    *   Sécurité renforcée avec headers sécurisés
    *   Performance maximisée avec cache agressif

### **🎯 Configuration VS Code Intégrée**
*   **Support Tailwind CSS v4** : IntelliSense complet avec autocomplétion
*   **Extensions Recommandées** : PHP IntelliSense, Twig, Tailwind CSS
*   **Configuration Optimisée** : Exclusions intelligentes pour de meilleures performances
*   **Reconnaissance des Fichiers** : Support automatique des templates Twig et PHP

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
    
    > ⚠️ **Important** : Pour l'instant, il est recommandé de **NE PAS lancer les commandes `npm run dev` et `npm run build` directement dans les conteneurs Docker**. Ces commandes doivent être exécutées sur votre machine hôte.
    
    ```bash
    # Naviguer vers votre thème directement sur votre machine hôte
    cd wp-content/themes/[VOTRE_THEME_NAME]
    
    # Installer les dépendances npm si nécessaire
    npm install
    
    # Lancer le mode développement avec watch + BrowserSync
    npm run dev
    ```
    
    **Pourquoi cette limitation ?**
    - Les performances de compilation Webpack sont meilleures sur l'hôte
    - BrowserSync fonctionne plus efficacement avec les ports de l'hôte
    - Évite les problèmes de permissions entre conteneur et hôte
    - Synchronisation des fichiers plus rapide
    
    **Prérequis sur votre machine hôte :**
    - Node.js 18+ (recommandé 22.10.0 pour correspondre au conteneur)
    - npm ou yarn

## 📁 Architecture Complète du Projet

### **Structure Générale**
```
wp-starter/
├── docker-compose.yml                    # Orchestration des services Docker
├── .env.example                         # Template de configuration
├── .env                                 # Configuration d'environnement (git-ignoré)
├── LICENSE                              # Licence MIT
├── README.md                            # Documentation complète (ce fichier)
│
├── docker/                              # Configuration Docker
│   ├── Dockerfile--wordpress            # Image WordPress personnalisée
│   ├── custom-entrypoint.sh            # Script d'initialisation principal
│   ├── scripts/                         # Scripts modulaires d'initialisation
│   │   ├── init-variables.sh           # Initialisation des variables d'environnement
│   │   ├── check-dependencies.sh       # Vérification des dépendances système
│   │   ├── setup-wordpress-core.sh     # Installation et configuration WordPress
│   │   ├── manage-themes.sh            # Gestion et installation des thèmes
│   │   ├── manage-plugins.sh           # Installation des plugins essentiels
│   │   ├── configure-redis.sh          # Configuration du cache Redis
│   │   ├── configure-msmtp.sh          # Configuration email SMTP
│   │   ├── finalize-config.sh          # Finalisation de la configuration
│   │   └── template-utils.sh           # Utilitaires de templating
│   └── templates/                       # Templates pour la génération automatique
│       └── custom-theme/                # Template du thème enfant
│           ├── style.css                # Informations du thème WordPress
│           ├── functions.php            # Fonctions PHP et enqueue assets
│           ├── package.json             # Dépendances npm et scripts de build
│           ├── webpack.config.js        # Configuration Webpack complète
│           ├── postcss.config.js        # Configuration PostCSS
│           ├── browsersync.config.js    # Configuration BrowserSync
│           ├── .gitignore              # Exclusions Git pour le thème
│           ├── assets/                  # Sources non compilées
│           │   ├── css/
│           │   │   └── styles.css       # CSS principal avec Tailwind v4
│           │   └── js/
│           │       └── scripts.js       # JavaScript ES6+ principal
│           └── inc/                     # Modules PHP
│               ├── performance.php      # Optimisations WordPress
│               └── security.php         # Sécurisations WordPress
│
└── wp-content/                          # Contenu WordPress persistant (mappé)
    ├── themes/                          # Thèmes WordPress
    │   ├── timber-starter-theme/        # Thème parent Timber (auto-installé)
    │   │   ├── composer.json           # Dépendances Timber
    │   │   ├── vendor/                 # Librairies PHP (Timber, Twig)
    │   │   ├── functions.php           # Fonctions du thème parent
    │   │   ├── views/                  # Templates Twig de base
    │   │   └── [autres fichiers...]
    │   │
    │   └── [CUSTOM_THEME_NAME]/         # Votre thème enfant (généré automatiquement)
    │       ├── style.css               # En-tête du thème enfant
    │       ├── functions.php           # Point d'entrée et enqueue des assets
    │       ├── .gitignore             # Exclusions (node_modules, dist, etc.)
    │       │
    │       ├── composer.json           # Dépendances PHP (copié du parent)
    │       ├── vendor/                 # Dépendances PHP Composer
    │       │
    │       ├── package.json            # Dépendances npm et scripts
    │       ├── package-lock.json       # Lockfile npm (auto-généré)
    │       ├── node_modules/           # Dépendances npm (auto-installées)
    │       │
    │       ├── webpack.config.js       # Configuration Webpack avancée
    │       ├── postcss.config.js       # Configuration PostCSS + Tailwind
    │       ├── browsersync.config.js   # Configuration BrowserSync
    │       │
    │       ├── assets/                 # Sources non compilées
    │       │   ├── css/
    │       │   │   └── styles.css      # CSS source avec Tailwind v4
    │       │   └── js/
    │       │       └── scripts.js      # JavaScript ES6+ source
    │       │
    │       ├── dev_build/              # Assets de développement (compilés)
    │       │   ├── main.js            # JavaScript avec source maps
    │       │   └── styles.css         # CSS non minifié avec source maps
    │       │
    │       ├── dist/                   # Assets de production (optimisés)
    │       │   ├── main.min.js        # JavaScript minifié et optimisé
    │       │   └── styles.min.css     # CSS minifié et optimisé
    │       │
    │       ├── inc/                    # Modules PHP organisés
    │       │   ├── performance.php     # Optimisations WordPress
    │       │   └── security.php       # Sécurisations WordPress
    │       └── views/                  # Templates Twig (à créer selon besoins)
    ├── plugins/                        # Plugins WordPress (auto-installés)
    │   ├── advanced-custom-fields/     # ACF pour les champs personnalisés
    │   ├── wordpress-seo/             # Yoast SEO pour le référencement
    │   ├── litespeed-cache/           # Cache et optimisations
    │   ├── contact-form-7/            # Formulaires de contact
    │   └── redis-cache/               # Cache d'objets Redis
    │
    ├── uploads/                        # Fichiers médias uploadés
    └── upgrade/                        # Fichiers de mise à jour WordPress
```
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
*   `WORDPRESS_SHOW_WARNINGS` : 
    *   `true` : Affiche les avertissements PHP pour le débogage
    *   `false` : Masque les avertissements pour une interface propre (recommandé)

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

> ⚠️ **Important** : Les commandes `npm run dev` et `npm run build` doivent être exécutées sur votre **machine hôte**, pas dans les conteneurs Docker, pour des raisons de performance et de compatibilité avec BrowserSync.

#### **Architecture des Assets**

Le système de build Webpack est configuré pour gérer intelligemment les environnements :

```bash
# Naviguer vers votre thème (sur votre machine hôte)
cd wp-content/themes/[CUSTOM_THEME_NAME]

# Structure des assets
assets/css/styles.css        # Source Tailwind CSS v4
assets/js/scripts.js         # Source JavaScript ES6+
dev_build/                   # Build de développement (non minifié)
dist/                        # Build de production (optimisé)
```

#### **Scripts NPM Disponibles**

```bash
# Mode développement avec watch + BrowserSync (sur l'hôte)
npm run dev
# - Compilation automatique en mode watch
# - BrowserSync sur localhost:3000
# - Source maps activées
# - Assets dans dev_build/

# Build de production (sur l'hôte)
npm run build  
# - Minification avec Terser
# - Optimisation CSS
# - Assets dans dist/
# - Cache busting automatique
```

#### **Configuration Tailwind CSS v4**

Le fichier `assets/css/styles.css` utilise la nouvelle syntaxe Tailwind v4 :

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

### **🎨 Architecture Détaillée du Thème Enfant**

Le thème enfant généré automatiquement suit une **architecture moderne et modulaire** inspirée des meilleures pratiques de développement frontend :

#### **📋 Fichiers de Configuration**

**`style.css`** - En-tête du thème WordPress
```css
/*
 * Theme Name: {{CUSTOM_THEME_SLUG}}
 * Template: {{STARTER_THEME_SLUG}}
 * Description: Thème enfant moderne basé sur Timber avec architecture Webpack 5 complète
 * Version: 1.0
 * Author: Lugh Web
*/
```

**`functions.php`** - Point d'entrée principal
- **Enqueue intelligent des assets** selon l'environnement
- **Cache busting automatique** avec `filemtime()`
- **Support ES6 modules** pour les scripts
- **Include des modules** `inc/security.php` et `inc/performance.php`
- **Désactivation de l'éditeur de blocs** pour un contrôle total

**`package.json`** - Gestion des dépendances npm
```json
{
  "name": "{{CUSTOM_THEME_SLUG}}",
  "scripts": {
    "dev": "webpack --mode=development --watch",
    "build": "webpack --mode=production"
  },
  "devDependencies": {
    "@babel/core": "^7.27.1",
    "@babel/preset-env": "^7.27.2",
    "@tailwindcss/postcss": "^4.1.7",
    "webpack": "^5.x.x",
    "browser-sync-webpack-plugin": "^2.3.0",
    "css-minimizer-webpack-plugin": "^7.0.2",
    "terser-webpack-plugin": "^5.3.14"
  }
}
```

#### **⚙️ Configuration Build**

**`webpack.config.js`** - Configuration Webpack avancée
- **Entrées multiples** : JavaScript et CSS séparés
- **Sortie conditionnelle** : `dev_build/` vs `dist/` selon l'environnement
- **Loaders configurés** :
  - Babel pour ES6+ → ES5
  - PostCSS pour Tailwind v4 + autoprefixer
  - CSS Loader avec extraction
- **Plugins d'optimisation** :
  - MiniCssExtractPlugin pour l'extraction CSS
  - TerserPlugin pour la minification JavaScript
  - CssMinimizerPlugin pour l'optimisation CSS
  - BrowserSyncPlugin pour le hot reload

**`postcss.config.js`** - Configuration PostCSS
```javascript
module.exports = {
  plugins: [
    require('postcss-import'),        // Support @import
    require('@tailwindcss/postcss'),  // Tailwind CSS v4
    require('autoprefixer'),          // Préfixes navigateurs
  ],
};
```

**`browsersync.config.js`** - Configuration BrowserSync
```javascript
module.exports = {
  proxy: "localhost:{{WORDPRESS_HOST_PORT}}",
  files: ["**/*.css", "**/*.php", "**/*.twig", "**/*.js"],
  port: 3000,
  ui: { port: 3001 }
};
```

#### **🎯 Sources Assets (`assets/`)**

**`assets/css/styles.css`** - CSS principal avec Tailwind v4
```css
/* Import Tailwind's base, components, and utilities for v4 */
@import "tailwindcss";

/* Content paths pour Tailwind v4 */
@content '../../views/**/*.twig';
@content '../../*.php';
@content '../js/**/*.js';

/* Layers personnalisables */
@layer base {
  /* Styles de base personnalisés */
}

@layer components {
  /* Composants réutilisables */
}

@layer utilities {
  /* Utilitaires personnalisés */
}

/* Variables CSS personnalisées */
@theme {
  /* Configuration Tailwind personnalisée */
}
```

**`assets/js/scripts.js`** - JavaScript ES6+ principal
```javascript
import { gsap } from 'gsap';
import '../css/styles.css';

addEventListener('DOMContentLoaded', function() {
   console.log('🔧 Webpack entry file loaded');
   
   // Initialisation GSAP
   gsap.from('.animate-in', {
     duration: 1,
     y: 50,
     opacity: 0,
     stagger: 0.2
   });
});
```

#### **📦 Assets Compilés**

**`dev_build/`** - Assets de développement
- **Source maps activées** pour debugging
- **Code non minifié** pour lisibilité
- **Hot reload** avec BrowserSync
- **Compilation rapide** pour productivité

**`dist/`** - Assets de production
- **Minification avancée** (Terser + CssMinimizerPlugin)
- **Tree shaking** pour réduire la taille
- **Optimisation images** (si configurée)
- **Hashing automatique** pour cache busting

#### **🔧 Modules PHP (`inc/`)**

**`inc/security.php`** - Sécurisations WordPress
```php
// Désactivation XML-RPC
add_filter('xmlrpc_enabled', '__return_false');

// Suppression des informations de version
function remove_wordpress_version() { return ''; }
add_filter('the_generator', 'remove_wordpress_version');

// Protection contre l'édition de fichiers
if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', true);
}

// Nettoyage des en-têtes sensibles
remove_action('wp_head', 'wp_generator');
remove_action('wp_head', 'wlwmanifest_link');
remove_action('wp_head', 'rsd_link');
```

**`inc/performance.php`** - Optimisations WordPress
```php
// Désactivation des styles de blocs inutiles
add_action('wp_enqueue_scripts', function () {
    wp_dequeue_style('wp-block-library');
    wp_dequeue_style('wp-block-library-theme');
    wp_dequeue_style('global-styles');
    wp_dequeue_style('classic-theme-styles');
}, 20);

// Suppression des emojis WordPress
function disable_emojis() {
    remove_action('wp_head', 'print_emoji_detection_script', 7);
    remove_action('wp_print_styles', 'print_emoji_styles');
    // ... autres optimisations
}
add_action('init', 'disable_emojis');

// Suppression REST API header
remove_action('wp_head', 'rest_output_link_wp_head', 10);
```

#### **🎭 Templates Twig (`views/`)**

Structure recommandée pour les templates :
```
views/
├── base.twig                 # Template de base HTML
├── index.twig               # Page d'accueil
├── single.twig              # Articles/pages individuelles
├── page.twig                # Pages statiques
├── archive.twig             # Pages d'archives
└── components/              # Composants réutilisables
    ├── header.twig          # En-tête du site
    ├── footer.twig          # Pied de page
    ├── navigation.twig      # Menu de navigation
    ├── sidebar.twig         # Barre latérale
    └── post-card.twig       # Carte d'article
```

**Exemple `views/base.twig`** :
```twig
<!DOCTYPE html>
<html {{ site.language_attributes }}>
<head>
    <meta charset="{{ site.charset }}">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {{ wp_head() }}
</head>
<body class="{{ body_class }}">
    
    {% include 'components/header.twig' %}
    
    <main class="main-content">
        {% block content %}{% endblock %}
    </main>
    
    {% include 'components/footer.twig' %}
    
    {{ wp_footer() }}
</body>
</html>
```

#### **🔄 Workflow de Build Intelligent**

**Détection automatique de l'environnement** dans `functions.php` :
```php
$wordpress_env = getenv('WORDPRESS_ENV');

if ($wordpress_env === 'development') {
    // Assets de développement
    $css_file = '/dev_build/styles.css';
    $js_file = '/dev_build/main.js';
} else {
    // Assets de production
    $css_file = '/dist/styles.min.css';
    $js_file = '/dist/main.min.js';
}

// Enqueue avec cache busting
wp_enqueue_style(
    'theme-styles',
    get_stylesheet_directory_uri() . $css_file,
    array(),
    filemtime(get_stylesheet_directory() . $css_file)
);
```

**Scripts npm optimisés** :
- `npm run dev` : Watch mode + BrowserSync + Source maps
- `npm run build` : Production build + Minification + Optimisation

Cette architecture garantit une **séparation claire des responsabilités**, une **performance optimale** et une **expérience de développement moderne** tout en respectant les standards WordPress et les meilleures pratiques de développement frontend.

## 🔧 Dépannage et FAQ

### **Problèmes Courants**

#### **🐳 Problèmes Docker**

**Les conteneurs ne démarrent pas**
```bash
# Vérifier les logs
docker compose logs

# Nettoyer et reconstruire
docker compose down
docker compose up -d --build --force-recreate
```

**Erreur "Port already in use"**
```bash
# Vérifier quel processus utilise le port
sudo lsof -i :8080

# Modifier le port dans .env
WORDPRESS_HOST_PORT=8081
```

**Problème de permissions de fichiers**
```bash
# Ajuster les permissions
sudo chown -R $USER:$USER wp-content/
sudo chmod -R 755 wp-content/
```

#### **🔧 Problèmes Build Frontend**

**Erreur "npm command not found" (dans le conteneur)**
> ⚠️ **Rappel** : Utilisez npm sur votre **machine hôte**, pas dans le conteneur Docker.

**BrowserSync ne fonctionne pas**
```bash
# Vérifier que WordPress est accessible
curl http://localhost:8080

# Vérifier les ports disponibles
netstat -tlnp | grep :3000
netstat -tlnp | grep :3001

# Redémarrer le build
npm run dev
```

**Assets non chargés en production**
```bash
# Vérifier que les fichiers dist/ existent
ls -la dist/

# Rebuilder les assets
npm run build

# Vérifier les permissions
chmod -R 644 dist/
```

#### **🚨 Problèmes WordPress**

**Site WordPress inaccessible**
```bash
# Vérifier l'état des conteneurs
docker compose ps

# Redémarrer les services
docker compose restart

# Vérifier les logs WordPress
docker compose logs wordpress
```

**Base de données non accessible**
```bash
# Le projet utilise maintenant netcat pour une vérification robuste de la connectivité
# Vérification automatique dans les scripts d'initialisation

# Tester manuellement la connexion
docker compose exec wordpress nc -z db 3306

# Tester la connexion à MySQL
docker compose exec db mysql -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD

# Vérifier les variables d'environnement
docker compose exec wordpress env | grep WORDPRESS_DB

# Diagnostic avancé de connectivité WordPress
docker compose exec wordpress wp db check --allow-root
```

**Emails ne fonctionnent pas**
```bash
# Tester msmtp
docker compose exec wordpress echo "Test" | msmtp --debug test@example.com

# Vérifier la configuration
docker compose exec wordpress cat ~/.msmtprc
```

### **🎯 Performance et Optimisation Production**

#### **Optimisations WordPress Avancées**

**Configuration wp-config.php recommandée pour la production**
```php
// Cache et performance
define('WP_CACHE', true);
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);
define('CONCATENATE_SCRIPTS', true);
define('ENFORCE_GZIP', true);

// Sécurité renforcée
define('DISALLOW_FILE_EDIT', true);
define('DISALLOW_FILE_MODS', true);
define('FORCE_SSL_ADMIN', true);

// Révisions et auto-save
define('WP_POST_REVISIONS', 3);
define('AUTOSAVE_INTERVAL', 300);

// Corbeille automatique
define('EMPTY_TRASH_DAYS', 7);
```

**Optimisations de base de données**
```bash
# Optimiser les tables
docker compose exec wordpress wp db optimize --allow-root

# Nettoyer les révisions
docker compose exec wordpress wp post delete $(wp post list --post_type='revision' --format=ids --allow-root) --allow-root

# Supprimer les commentaires spam
docker compose exec wordpress wp comment delete $(wp comment list --status=spam --format=ids --allow-root) --allow-root
```

#### **Configuration Redis pour la Production**

**Optimisation du cache d'objets Redis**
```bash
# Vérifier l'état de Redis
docker compose exec redis redis-cli ping

# Statistiques du cache
docker compose exec wordpress wp redis status --allow-root

# Vider le cache si nécessaire
docker compose exec wordpress wp redis flush --allow-root
```

#### **Monitoring de Performance**

**Scripts de monitoring inclus**
```bash
# Vérifier l'utilisation mémoire des conteneurs
docker stats

# Analyser les temps de réponse
docker compose exec wordpress wp db check --allow-root
```

## 🔄 Mise à Jour et Maintenance

### **Mise à Jour WordPress**
```bash
# Mettre à jour WordPress Core
docker compose exec wordpress wp core update --allow-root

# Mettre à jour les plugins
docker compose exec wordpress wp plugin update --all --allow-root

# Mettre à jour les thèmes
docker compose exec wordpress wp theme update --all --allow-root
```

### **Mise à Jour des Dépendances**

**Dépendances PHP**
```bash
cd wp-content/themes/[VOTRE_THEME]
composer update
```

**Dépendances npm**
```bash
cd wp-content/themes/[VOTRE_THEME]
npm update
npm audit fix
```

**Images Docker**
```bash
# Mettre à jour les images
docker compose pull
docker compose up -d --build
```

### **Sauvegarde et Restauration**

**Sauvegarde complète**
```bash
# Base de données
docker compose exec wordpress wp db export backup-$(date +%Y%m%d).sql --allow-root

# Fichiers wp-content
tar -czf wp-content-backup-$(date +%Y%m%d).tar.gz wp-content/

# Configuration
cp .env .env.backup-$(date +%Y%m%d)
```

**Restauration**
```bash
# Restaurer la base de données
docker compose exec wordpress wp db import backup-YYYYMMDD.sql --allow-root

# Restaurer les fichiers
tar -xzf wp-content-backup-YYYYMMDD.tar.gz
```

### **Checklist de Déploiement**

- [ ] Variables d'environnement sécurisées
- [ ] SSL/TLS configuré
- [ ] Builds de production générées (`npm run build`)
- [ ] Cache Redis activé
- [ ] Sauvegardes automatiques configurées
- [ ] Monitoring des logs activé
- [ ] Tests de performance effectués
- [ ] Sécurité WordPress renforcée

## 🤝 Contribution

### **Comment Contribuer**

1. **Fork du projet**
2. **Créer une branche** : `git checkout -b feature/amelioration`
3. **Commiter les changements** : `git commit -m 'Ajout d'une fonctionnalité'`
4. **Pousser la branche** : `git push origin feature/amelioration`
5. **Ouvrir une Pull Request**

### **Guidelines de Contribution**

- **Code Style** : Respecter les standards PSR-12 pour PHP et Prettier pour JavaScript
- **Documentation** : Documenter toute nouvelle fonctionnalité
- **Tests** : Ajouter des tests si applicable
- **Commits** : Messages de commit clairs et descriptifs en français

### **Structure des Commits**
```
feat: ajout de nouvelle fonctionnalité
fix: correction de bug
docs: mise à jour documentation
style: formatage code
refactor: refactorisation
test: ajout de tests
chore: tâches de maintenance
```

## 🐛 Rapporter un Bug

### **Avant de Rapporter**
- Vérifiez que le bug n'a pas déjà été rapporté
- Testez avec la dernière version
- Consultez la section dépannage

### **Informations à Inclure**
- Version du projet
- Version de Docker/Docker Compose
- Système d'exploitation
- Logs d'erreur complets
- Étapes pour reproduire le bug

## 🛡️ Sécurité

### **Signaler une Vulnérabilité**
Pour signaler une vulnérabilité de sécurité, **ne pas** créer d'issue publique. 
Contactez directement : [security@lughweb.fr](mailto:security@lughweb.fr)

### **Bonnes Pratiques de Sécurité**
- Utilisez des mots de passe forts
- Maintenez WordPress et les plugins à jour
- Utilisez HTTPS en production
- Sauvegardez régulièrement
- Surveillez les logs d'accès

## 📈 Roadmap

### **Fonctionnalités Prévues**
- [ ] Support Docker dans conteneur pour npm (résolution des limitations actuelles)
- [ ] Intégration CI/CD avec GitHub Actions
- [ ] Template d'images Docker optimisées
- [ ] Support PWA (Progressive Web App)
- [ ] Intégration Elasticsearch pour la recherche avancée
- [ ] Support multi-sites WordPress
- [ ] Templates de déploiement AWS/DigitalOcean
- [ ] Monitoring avec Prometheus/Grafana

### **Versions Futures**
- **v2.0** : Intégration complète npm dans Docker
- **v2.1** : Support Kubernetes
- **v2.2** : Outils d'A/B testing intégrés

## 🙏 Remerciements

### **Technologies et Projets**
- [WordPress](https://wordpress.org/) - CMS de référence
- [Timber](https://timber.github.io/docs/) - Templating moderne pour WordPress
- [Docker](https://www.docker.com/) - Containerisation
- [Webpack](https://webpack.js.org/) - Bundler moderne
- [Tailwind CSS](https://tailwindcss.com/) - Framework CSS utility-first
- [GSAP](https://greensock.com/gsap/) - Animations JavaScript
- [BrowserSync](https://browsersync.io/) - Synchronisation de développement

### **Communauté**
Merci à tous les contributeurs et à la communauté WordPress pour leurs contributions et retours.

---

## 📜 Licence

Ce projet est sous licence **MIT**. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

### **Licence MIT - Résumé**
- ✅ Usage commercial autorisé
- ✅ Modification autorisée
- ✅ Distribution autorisée
- ✅ Usage privé autorisé
- ❌ Aucune garantie fournie
- ❌ Responsabilité limitée

---

**Fait avec ❤️ par [Lugh Web](https://lughweb.fr)**
