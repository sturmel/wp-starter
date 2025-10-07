# WordPress Starter Kit avec Docker, Timber, Webpack 5, Tailwind CSS v4 et GSAP

> **Proposé par [Lugh Web](https://lugh-web.fr)** - Agence web spécialisée dans le développement WordPress moderne

Ce projet est un **kit de démarrage professionnel** pour développer des sites WordPress modernes et performants en utilisant Docker. Il fournit un environnement de développement local complet, préconfiguré avec WordPress, MySQL, Redis, phpMyAdmin, et une chaîne de compilation moderne basée sur **Webpack 5**.

Le système génère automatiquement un **thème enfant intelligent** basé sur `timber-starter-theme` avec une architecture frontend complète incluant **Tailwind CSS v4**, **GSAP**, **BrowserSync**, et des outils d'optimisation avancés. Le thème suit les meilleures pratiques de développement moderne avec une séparation claire entre le backend PHP/Twig et le frontend JavaScript/CSS.

## 🧱 Aperçu de la Pile Technique

| Service      | Image Docker               | Description                                |
|--------------|----------------------------|--------------------------------------------|
| wordpress    | `wordpress:php8.4-apache`  | Serveur WordPress avec PHP 8.4 et Apache   |
| db           | `mysql:8.0`                | Base de données MySQL 8.0                  |
| redis        | `redis:alpine`             | Cache d'objets Redis pour les performances |
| phpmyadmin   | `phpmyadmin/phpmyadmin`    | Interface web pour gérer MySQL (port 8081) |

Le conteneur WordPress utilise l'image officielle sans Dockerfile personnalisé. Tout le répertoire `/var/www/html` est monté en liaison (bind-mount), donc tous les fichiers WordPress (noyau, extensions, thèmes, médias) sont accessibles dans le dossier `./wordpress` sur votre machine hôte.

## 🚀 Fonctionnalités Principales

### **🐳 Environnement de Développement Dockerisé**

*   **Services Complets** : WordPress, MySQL, Redis et phpMyAdmin gérés via `docker compose`
*   **Contenu Persistant** : Le dossier `./wordpress` est mappé pour conserver vos données entre les sessions
*   **Configuration Simple** : Toute la configuration via un fichier `.env`

### **🎨 Thème Enfant Timber Intelligent avec Architecture Moderne**

*   **Génération Automatique** : Création complète d'un thème enfant basé sur `timber-starter-theme`
*   **Personnalisation** : Nom du thème configurable via `CUSTOM_THEME_NAME`
*   **Dépendances Gérées** : 
    *   `composer.json` avec Timber installé automatiquement
    *   `package.json` généré avec toutes les dépendances npm modernes
    *   Installation automatique des packages lors de la première initialisation
*   **Architecture Modulaire** : 
    *   `inc/` : Modules PHP (sécurité, performance)
    *   `views/` : Gabarits Twig organisés
    *   `assets/` : Fichiers sources CSS/JS non compilés
    *   `dist/` : Ressources de production optimisées
    *   `dev_build/` : Ressources de développement avec cartes sources (source maps)

### **⚡ Chaîne de Compilation Webpack 5 Complète**

*   **Configuration Avancée** : Webpack configuré pour le développement et la production
*   **Compilation Intelligente selon l'Environnement** : 
    *   **Mode développement** : Compilation dans `dev_build/` avec cartes sources et rechargement automatique
    *   **Mode production** : Compilation hautement optimisée dans `dist/` avec minification agressive, suppression du code inutilisé (tree-shaking) et optimisations avancées
*   **Rechargement Automatique** : Compilation automatique en mode surveillance avec BrowserSync
*   **Optimisation Poussée des Ressources** : 
    *   **JavaScript** : Minification avancée avec `TerserPlugin` (suppression des `console.log`, code mort) et support ES6+
    *   **CSS** : Optimisation extrême avec `CssMinimizerPlugin` et PostCSS
    *   **Élimination du Code Inutilisé** : Suppression automatique du code JavaScript non utilisé en production
    *   Nettoyage automatique des compilations précédentes
### **🎯 Interface Utilisateur Moderne et Optimisée**

*   **Tailwind CSS v4** : Framework CSS utilitaire avec la nouvelle architecture
    *   Support complet des directives `@import "tailwindcss"`
    *   Configuration `@content` pour la détection automatique des classes
    *   Couches personnalisables (`@layer base`, `@layer components`, `@layer utilities`)
    *   Variables personnalisées avec `@theme`
    *   PostCSS intégré avec autoprefixer
*   **JavaScript ES6+ Moderne** :
    *   Support complet ES6+ avec Babel et préréglages modernes
    *   Modules ES6 supportés nativement
    *   GSAP inclus pour les animations fluides
    *   Regroupement intelligent avec possibilité de division du code
*   **Système de Gabarits Twig** :
    *   Séparation logique entre PHP et gabarits
    *   Architecture MVC avec Timber
    *   Réutilisabilité des composants
    *   Sécurité accrue avec échappement automatique

### **🔧 Outils de Développement Intégrés**

*   **BrowserSync Pro** : 
    *   Synchronisation en temps réel sur le port 3000
    *   Injection CSS à chaud sans rechargement de page
    *   Interface de contrôle avancée sur le port 3001
    *   Proxy automatique vers WordPress (port configuré)
    *   Synchronisation multi-appareils
*   **Scripts NPM Optimisés** :
    *   `npm run dev` : Mode développement avec surveillance automatique et BrowserSync
    *   `npm run build` : Compilation de production avec minification complète
*   **Optimisation Production Avancée** :
    *   Minification JavaScript avec Terser et optimisations ES6
    *   Compression CSS optimisée avec suppression des doublons
    *   Suppression automatique du code inutilisé pour réduire la taille des paquets
    *   Invalidation automatique du cache avec versions basées sur `filemtime()`

### **🛠️ Stack Technique Complet**

*   **Backend WordPress Optimisé** : 
    *   WP-CLI intégré dans le conteneur pour administration
    *   Composer pour la gestion des dépendances PHP
    *   Timber (fourni via Composer dans le thème) pour l'architecture MVC
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
    *   Extension de conformité RGPD préinstallée : Complianz GDPR

## 📋 Prérequis

*   [Docker](https://docs.docker.com/get-docker/)
*   [Docker Compose](https://docs.docker.com/compose/install/) (généralement inclus avec Docker Desktop)
*   **Node.js** (optionnel, pour le développement frontend) - recommandé : version 16+
*   Un navigateur moderne pour tester les fonctionnalités frontend

## 🚀 Démarrage Rapide

### Étape 1 : Cloner le Dépôt

Commencez par récupérer le code source sur votre machine :

```bash
git clone https://github.com/sturmel/funtechadventures.com--wp.git
cd funtechadventures.com--wp
```

### Étape 2 : Configurer les Variables d'Environnement

Créez votre fichier de configuration en copiant l'exemple fourni :

```bash
cp .env.example .env
```

Ouvrez le fichier `.env` avec votre éditeur de texte préféré et ajustez les valeurs selon vos besoins :

```bash
nano .env  # ou vim .env, ou code .env avec VS Code
```

**Configuration minimale requise :**

```bash
# Identifiants de la base de données
WORDPRESS_DB_USER=admin
WORDPRESS_DB_PASSWORD=VotreMotDePasseSecurise123
WORDPRESS_DB_NAME=wordpress_db
MYSQL_ROOT_PASSWORD=MotDePasseRootSecurise456

# Configuration de base WordPress
WORDPRESS_URL=http://localhost:8080
WORDPRESS_TITLE="Mon Site WordPress"
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_PASSWORD=AdminSecurise789
WORDPRESS_ADMIN_EMAIL=votre.email@example.com
WORDPRESS_TABLE_PREFIX=wp_
CUSTOM_THEME_NAME="Mon Thème Personnalisé"

# Ports d'accès (modifiez si nécessaire)
WORDPRESS_HOST_PORT=8080
PHPMYADMIN_HOST_PORT=8081
```

**⚠️ Important :** Utilisez des mots de passe forts et uniques pour chaque environnement.

### Étape 3 : Démarrer les Conteneurs Docker

Lancez l'infrastructure complète avec une seule commande :

```bash
docker compose up -d
```

Cette commande va :
- Télécharger toutes les images Docker nécessaires (WordPress, MySQL, Redis, phpMyAdmin)
- Créer les conteneurs et les réseaux
- Démarrer tous les services en arrière-plan
- Créer automatiquement le répertoire `wordpress/` et y installer WordPress

**Note :** Le premier démarrage peut prendre quelques minutes selon votre connexion internet.

### Étape 4 : Installer et Configurer WordPress

Exécutez le script de provisionnement automatique :

```bash
./scripts/setup-wordpress.sh
```

**Ce script effectue automatiquement les tâches suivantes :**

1. ✅ Vérifie que les conteneurs Docker sont démarrés
2. ✅ Attend que MySQL soit complètement prêt
3. ✅ Installe WP-CLI (outil en ligne de commande WordPress) dans le conteneur
4. ✅ Installe Composer (gestionnaire de dépendances PHP) dans le conteneur
5. ✅ Génère le fichier `wp-config.php` avec vos paramètres du `.env`
6. ✅ Installe le noyau WordPress et crée votre compte administrateur
7. ✅ Installe et active les extensions essentielles :
   - Advanced Custom Fields (champs personnalisés)
   - Rank Math SEO (référencement et optimisation SEO)
   - LiteSpeed Cache (performances et cache)
   - Contact Form 7 (formulaires de contact)
   - Complianz GDPR (conformité RGPD)
8. ✅ Installe le thème parent Timber via Composer
9. ✅ Crée votre thème enfant personnalisé depuis le modèle `scripts/custom-theme/`
10. ✅ Applique les substitutions de variables (nom du thème, ports, etc.)
11. ✅ Active automatiquement votre thème enfant
12. ✅ Installe les dépendances npm (si Node.js est disponible sur votre machine)

**Le script est idempotent** : vous pouvez le relancer plusieurs fois sans problème, il ne ré-exécutera que les étapes nécessaires.

### Étape 5 : Accéder à Votre Site WordPress

Une fois l'installation terminée, accédez à votre site via les URLs suivantes :

- **🌐 Site WordPress** : `http://localhost:8080` (ou le port configuré dans `WORDPRESS_HOST_PORT`)
- **👤 Administration WordPress** : `http://localhost:8080/wp-admin`
  - Identifiant : celui défini dans `WORDPRESS_ADMIN_USER`
  - Mot de passe : celui défini dans `WORDPRESS_ADMIN_PASSWORD`
- **🗄️ phpMyAdmin** : `http://localhost:8081`
  - Serveur : `db`
  - Utilisateur : celui défini dans `WORDPRESS_DB_USER`
  - Mot de passe : celui défini dans `WORDPRESS_DB_PASSWORD`

### Étape 6 : Démarrer le Développement Frontend (Optionnel)

Si vous souhaitez travailler sur l'apparence et les fonctionnalités frontend de votre thème avec rechargement automatique :

```bash
# Naviguez vers le répertoire de votre thème
cd wordpress/wp-content/themes/mon-theme-personnalise  # Remplacez par votre slug de thème

# Installez les dépendances npm (si ce n'est pas déjà fait)
npm install

# Démarrez le mode développement avec surveillance automatique
npm run dev
```

**Résultat :** BrowserSync sera accessible sur `http://localhost:3000` avec rechargement automatique à chaque modification de vos fichiers CSS, JS, PHP ou Twig.

---

**✅ Votre environnement de développement WordPress est maintenant opérationnel !**

## 📜 Scripts de Gestion et d'Automatisation

Ce projet inclut plusieurs scripts shell pour automatiser et simplifier la gestion de votre environnement WordPress. Tous les scripts sont situés dans le répertoire `scripts/` et sont conçus pour être exécutés depuis la racine du projet.

### 🚀 `setup-wordpress.sh` - Installation Complète Initiale

**Utilisation :**
```bash
./scripts/setup-wordpress.sh
```

**Description :**
Script principal d'installation et de configuration de WordPress. C'est le script à exécuter après votre premier `docker compose up -d`.

**Fonctionnalités :**
- ✅ Vérifie et démarre les conteneurs Docker si nécessaire
- ✅ Attend que MySQL soit complètement opérationnel
- ✅ Installe **WP-CLI** dans le conteneur WordPress
- ✅ Installe **Composer** dans le conteneur WordPress
- ✅ Installe **Node.js 22.x LTS** dans le conteneur WordPress
- ✅ Configure les plugins autorisés pour Composer
- ✅ Génère `wp-config.php` avec les paramètres du `.env`
- ✅ Ajoute la configuration Redis pour LiteSpeed Cache
- ✅ Installe le noyau WordPress
- ✅ Crée le compte administrateur
- ✅ Installe et active les plugins essentiels :
  - Advanced Custom Fields (ACF)
  - Rank Math SEO
  - LiteSpeed Cache
  - Contact Form 7
  - Complianz GDPR
- ✅ Installe le thème parent `timber-starter-theme` via Composer
- ✅ Crée votre thème enfant personnalisé depuis le template
- ✅ Applique les substitutions de variables (`{{CUSTOM_THEME_SLUG}}`, etc.)
- ✅ Active automatiquement votre thème personnalisé
- ✅ Installe le drop-in `object-cache.php` pour Redis
- ✅ Installe les dépendances npm du thème dans le conteneur

**Caractéristiques :**
- **Idempotent** : Peut être relancé sans risque, ne refait que ce qui est nécessaire
- **Autonome** : Installe tous les outils requis (WP-CLI, Composer, Node.js) dans le conteneur
- **Sécurisé** : Vérifie les variables d'environnement requises avant de commencer

**Quand l'utiliser :**
- Première installation après `docker compose up -d`
- Après avoir supprimé le dossier `wordpress/`
- Pour réinitialiser complètement WordPress (avec `docker compose down -v` avant)

---

### 🔄 `migrate.sh` - Migration et Mise à Jour

**Utilisation :**
```bash
./scripts/migrate.sh
```

**Description :**
Script de migration non-destructif pour mettre à jour la configuration et les dépendances sans perdre de données.

**Fonctionnalités :**
- ✅ Régénère `wp-config.php` à partir du `.env` (clés de sécurité fraîches)
- ✅ Démarre les conteneurs Docker (`docker compose up -d`)
- ✅ Attend que MySQL et WordPress soient prêts
- ✅ Installe Composer dans le conteneur s'il est manquant
- ✅ Installe Node.js 22.x LTS dans le conteneur s'il est manquant
- ✅ Exécute `composer install` dans `timber-starter-theme/`
- ✅ Exécute `npm install` dans votre thème personnalisé

**Caractéristiques :**
- **Non-destructif** : AUCUNE suppression de données, conteneurs ou volumes
- **Intelligent** : Détecte et installe uniquement ce qui manque
- **Rapide** : Idéal pour les mises à jour de dépendances

**Quand l'utiliser :**
- Après avoir modifié votre `.env` (pour régénérer `wp-config.php`)
- Après `docker compose down -v` (pour réinstaller Composer/Node.js)
- Pour mettre à jour les dépendances npm ou Composer
- Après avoir cloné le projet sur une nouvelle machine
- Pour s'assurer que l'environnement est à jour

**Différence avec `setup-wordpress.sh` :**
- ❌ Ne touche PAS à WordPress (pas de réinstallation)
- ❌ Ne touche PAS aux plugins
- ❌ Ne touche PAS aux thèmes
- ✅ Focus uniquement sur la configuration et les dépendances

---

### ⚙️ `generate-wp-config.sh` - Générateur de Configuration WordPress

**Utilisation :**
```bash
./scripts/generate-wp-config.sh
```

**Description :**
Génère ou régénère le fichier `wordpress/wp-config.php` en se basant uniquement sur les variables du fichier `.env`.

**Fonctionnalités :**
- ✅ Lit les variables depuis `.env`
- ✅ Génère des clés de sécurité WordPress fraîches depuis l'API officielle
- ✅ Crée un fichier `wp-config.php` complet et sécurisé
- ✅ Configure la connexion à la base de données
- ✅ Ajoute la configuration Redis si `REDIS_ENABLED=true`
- ✅ Ajoute la configuration multisite si `WP_MULTISITE=true`
- ✅ Définit les permissions appropriées (644)

**Variables utilisées depuis `.env` :**
```bash
WORDPRESS_DB_NAME          # Nom de la base de données
WORDPRESS_DB_USER          # Utilisateur MySQL
WORDPRESS_DB_PASSWORD      # Mot de passe MySQL
WORDPRESS_TABLE_PREFIX     # Préfixe des tables (défaut: wp_)
REDIS_ENABLED             # Optionnel: active Redis
WP_MULTISITE              # Optionnel: active le multisite
WP_SUBDOMAIN_INSTALL      # Optionnel: multisite par sous-domaines
DOMAIN_CURRENT_SITE       # Optionnel: domaine principal du multisite
```

**Quand l'utiliser :**
- Après avoir modifié les identifiants de base de données dans `.env`
- Pour régénérer les clés de sécurité WordPress
- Si `wp-config.php` a été corrompu ou supprimé
- Pour activer/désactiver Redis ou le multisite

**Note :**
Ce script est automatiquement appelé par `migrate.sh`, mais peut aussi être utilisé de manière indépendante.

---

### 🧪 `test-redis.sh` - Test de Configuration Redis

**Utilisation :**
```bash
./scripts/test-redis.sh
```

**Description :**
Script de diagnostic complet pour vérifier que Redis est correctement configuré et opérationnel avec LiteSpeed Cache.

**Tests effectués :**
1. ✅ **Conteneur Redis** - Vérifie que le conteneur Redis est démarré
2. ✅ **Extension PHP Redis** - Vérifie que l'extension PHP Redis est installée et affiche la version
3. ✅ **Connexion Redis** - Test de lecture/écriture pour valider la connexion
4. ✅ **Drop-in object-cache.php** - Vérifie la présence du fichier
5. ✅ **Configuration wp-config.php** - Vérifie que les constantes Redis sont définies
6. ✅ **Informations Redis** - Affiche la version et les statistiques du serveur Redis

**Sortie exemple :**
```
═══════════════════════════════════════
  Test de configuration Redis
═══════════════════════════════════════

1. Vérification du conteneur Redis... ✓
2. Vérification de l'extension PHP Redis... ✓
   Version: 6.2.0
3. Test de connexion à Redis... ✓
4. Vérification du drop-in object-cache.php... ✓
5. Vérification de wp-config.php... ✓
   Configuration Redis trouvée dans wp-config.php

6. Informations Redis:
   redis_version:8.2.2
   os:Linux 6.12.5-linuxkit x86_64
   uptime_in_seconds:423

═══════════════════════════════════════
  Tests terminés avec succès !
═══════════════════════════════════════
```

**Quand l'utiliser :**
- Après l'installation pour vérifier que Redis fonctionne
- Avant d'activer Object Cache dans LiteSpeed Cache
- En cas de problème de performance ou de cache
- Pour diagnostiquer des erreurs liées à Redis

**Documentation associée :**
Consultez `/docs/REDIS_SETUP.md` pour le guide complet de configuration Redis avec LiteSpeed Cache.

---

### 📋 Résumé des Scripts

| Script | Utilisation | Destructif ? | Quand l'utiliser |
|--------|-------------|--------------|------------------|
| **setup-wordpress.sh** | Installation complète | ⚠️ Oui (si WordPress existe) | Première installation |
| **migrate.sh** | Mise à jour config + deps | ❌ Non | Après modifications du .env |
| **generate-wp-config.sh** | Générer wp-config.php | ⚠️ Écrase wp-config.php | Changement de config DB |
| **test-redis.sh** | Tester Redis | ❌ Non | Diagnostic Redis |

### 💡 Workflows Recommandés

**Premier démarrage du projet :**
```bash
cp .env.example .env          # Configurer vos variables
nano .env                      # Personnaliser
docker compose up -d          # Démarrer les conteneurs
./scripts/setup-wordpress.sh  # Installation complète
./scripts/test-redis.sh       # Vérifier Redis
```

**Après un `docker compose down -v` :**
```bash
docker compose up -d          # Redémarrer avec volumes vides
./scripts/migrate.sh          # Régénérer config + réinstaller dépendances
```

**Mise à jour des dépendances uniquement :**
```bash
./scripts/migrate.sh          # Met à jour Composer et npm
```

**Changement de configuration base de données :**
```bash
nano .env                            # Modifier WORDPRESS_DB_*
./scripts/generate-wp-config.sh     # Régénérer wp-config.php
docker compose restart wordpress    # Redémarrer WordPress
```

---

## 📂 Structure du Dépôt

```
.
├── docker-compose.yml          # Définit WordPress, MySQL, Redis, phpMyAdmin
├── Dockerfile                  # Image WordPress personnalisée avec Redis
├── scripts/
│   ├── setup-wordpress.sh      # Script d'installation complète
│   ├── migrate.sh             # Script de migration non-destructif
│   ├── generate-wp-config.sh   # Générateur de wp-config.php
│   ├── test-redis.sh          # Script de diagnostic Redis
│   └── custom-theme/           # Template du thème Timber copié par les scripts
│       ├── style.css
│       ├── functions.php
│       ├── package.json
│       ├── webpack.config.js
│       ├── postcss.config.js
│       ├── browsersync.config.js
│       ├── tailwind.config.js
│       ├── .gitignore
│       ├── assets/
│       │   ├── css/
│       │   │   └── styles.css
│       │   └── js/
│       │       └── scripts.js
│       └── inc/
│           ├── performance.php
│           └── security.php
├── templates/
│   └── object-cache.php       # Drop-in Redis pour LiteSpeed Cache
├── wordpress/                  # Installation complète WordPress (core + wp-content)
│   └── wp-content/
│       ├── themes/
│       │   ├── timber-starter-theme/  # Thème parent (auto-installé)
│       │   └── {custom-slug}/         # Votre thème enfant (auto-créé)
│       ├── plugins/            # Plugins installés automatiquement
│       └── uploads/            # Fichiers médias
├── .env.example                # Template des variables d'environnement
└── README.md                   # Cette documentation
```

## ✅ Dépannage

### Problèmes Courants

**Le script signale des erreurs `command not found` lors du sourcing de `.env`**
- Assurez-vous que toute valeur contenant des espaces est entre guillemets.

**Échec de `npm install` pour le thème custom**
- Les scripts `setup-wordpress.sh` et `migrate.sh` installent automatiquement Node.js 22.x LTS dans le conteneur WordPress si nécessaire.

**Les conteneurs ne démarrent pas**
- Vérifiez que les identifiants de la base de données dans `.env` correspondent à la fois aux variables d'environnement WordPress et MySQL.

**Redis ne s'active pas dans LiteSpeed Cache**
- Utilisez `./scripts/test-redis.sh` pour diagnostiquer les problèmes Redis.
- Le script vérifie l'extension PHP, la connexion, et le drop-in `object-cache.php`.

**Pour repartir de zéro**
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

```bash
docker compose down -v
rm -rf wordpress/
cp .env.example .env  # Reconfigurez vos variables
docker compose up -d
./scripts/setup-wordpress.sh
```

## 📜 Scripts Disponibles

### Script Principal : `setup-wordpress.sh`

Le script de provisionnement principal qui configure l'ensemble de l'environnement.

```bash
./scripts/setup-wordpress.sh
```

**Ce qu'il fait :**
- Démarre les conteneurs si nécessaire
- Attend que MySQL soit prêt
- Installe WP-CLI et Composer dans le conteneur
- Crée `wp-config.php` avec les bonnes valeurs
- Installe le noyau WordPress
- Installe et active les extensions par défaut (ACF, Rank Math SEO, LiteSpeed Cache, Contact Form 7, Complianz GDPR)
- Installe le thème starter Timber via Composer
- Copie et configure votre thème personnalisé depuis `scripts/custom-theme/`
- Exécute `npm install` si Node.js est disponible sur l'hôte

### Script Alternatif : `generate-wp-config.sh`

Générateur alternatif de `wp-config.php` si vous préférez ne pas utiliser WP-CLI.

```bash
./scripts/generate-wp-config.sh
```

## 🎨 Développement du Thème

### Structure du Thème Personnalisé

Le modèle du thème se trouve dans `scripts/custom-theme/` et sera copié vers `wordpress/wp-content/themes/{votre-slug}/` lors de l'exécution du script de configuration.

**Fichiers inclus dans le template :**

```
scripts/custom-theme/
├── style.css                # En-tête du thème WordPress
├── functions.php            # Enqueue des assets et configuration
├── .gitignore              # Exclusions Git
├── package.json            # Dépendances npm et scripts
├── webpack.config.js       # Configuration Webpack
├── postcss.config.js       # Configuration PostCSS + Tailwind
├── browsersync.config.js   # Configuration BrowserSync
├── tailwind.config.js      # Configuration Tailwind CSS
├── assets/
│   ├── css/
│   │   └── styles.css      # CSS source avec Tailwind v4
│   └── js/
│       └── scripts.js      # JavaScript ES6+ source
└── inc/
    ├── performance.php     # Optimisations WordPress
    └── security.php        # Sécurisations WordPress
```

### Scripts NPM du Thème

Une fois dans le répertoire du thème (`wordpress/wp-content/themes/{votre-slug}/`) :

```bash
# Installation des dépendances
npm install

# Mode développement avec watch et BrowserSync
npm run dev

# Build de production optimisé
npm run build
```

### Substitution de Variables

Le script remplace automatiquement ces placeholders dans les fichiers du template :

- `{{CUSTOM_THEME_SLUG}}` → Votre slug de thème (depuis `.env`)
- `{{STARTER_THEME_SLUG}}` → `timber-starter-theme`
- `{{WORDPRESS_HOST_PORT}}` → Port configuré (défaut `8080`)

## 📊 Commandes Docker Utiles

```bash
# Démarrer les services
docker compose up -d

# Arrêter les services
docker compose down

# Arrêter et supprimer les volumes (ATTENTION : perte de données)
docker compose down -v

# Voir les logs
docker compose logs -f wordpress
docker compose logs -f db

# Redémarrer un service
docker compose restart wordpress

# Entrer dans un conteneur
docker compose exec wordpress bash
docker compose exec db mysql -u root -p

# Voir l'état des conteneurs
docker compose ps
```

## 🔧 Personnalisation Avancée

### Ajouter des Plugins par Défaut

Éditez `scripts/setup-wordpress.sh` et ajoutez vos plugins à la liste :

```bash
install_plugins() {
  local plugins=(
    advanced-custom-fields
    seo-by-rank-math
    litespeed-cache
    contact-form-7
    complianz-gdpr
    # Ajoutez vos plugins ici
    mon-plugin-favori
  )
  # ...
}
```

### Modifier le Template du Thème

Les fichiers dans `scripts/custom-theme/` sont copiés à chaque exécution du script. Vous pouvez :

1. Modifier les fichiers dans `scripts/custom-theme/`
2. Relancer `./scripts/setup-wordpress.sh`
3. Les variables seront re-substituées (vos modifications dans le thème généré seront écrasées)

**Astuce :** Une fois le thème généré, travaillez directement dans `wordpress/wp-content/themes/{votre-slug}/` pour vos développements quotidiens.

## 🌐 Configuration de Production

Pour un déploiement en production, ajustez ces variables dans votre `.env` :

```bash
# Mode production
WORDPRESS_ENV=production

# Désactiver le debug
WP_DEBUG=false

# Sécurité renforcée
DISALLOW_FILE_EDIT=true

# Cache Redis
REDIS_ENABLED=true
```

Puis buildez les assets en mode production :

```bash
cd wordpress/wp-content/themes/{votre-slug}
npm run build
```

## 📚 Ressources et Documentation

### WordPress & Timber

- [Documentation WordPress](https://developer.wordpress.org/)
- [Timber Documentation](https://timber.github.io/docs/)
- [Twig Documentation](https://twig.symfony.com/)
- [WP-CLI Commands](https://developer.wordpress.org/cli/commands/)

### Outils Frontend

- [Tailwind CSS v4](https://tailwindcss.com/)
- [Documentation Webpack](https://webpack.js.org/)
- [BrowserSync](https://browsersync.io/)
- [GSAP](https://gsap.com/)

### Docker

- [Documentation Docker](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 🙏 Crédits

**Développé et maintenu par [Lugh Web](https://lugh-web.fr)**

Lugh Web est une agence web spécialisée dans le développement WordPress moderne et performant. Nous créons des solutions web sur mesure en utilisant les dernières technologies et les meilleures pratiques du développement.

### 🌐 Nous Contacter

- **Site web** : [https://lugh-web.fr](https://lugh-web.fr)
- **Email** : contact@lugh-web.fr
- **GitHub** : [@lugh-web](https://github.com/sturmel)

### 💼 Nos Services

- Développement WordPress sur mesure
- Création de thèmes personnalisés
- Optimisation des performances
- Hébergement et maintenance
- Conseil technique

---

**Fait avec ❤️ par Lugh Web** | *Happy coding! 🎉*

