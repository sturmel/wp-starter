# WordPress Starter Kit avec Docker

Ce projet est un kit de démarrage pour développer des sites WordPress en utilisant Docker. Il fournit un environnement de développement local complet, préconfiguré avec WordPress, MySQL, Redis, WP-CLI, Composer, Node.js et msmtp pour l'envoi d'e-mails.

## Fonctionnalités

*   **Environnement Dockerisé** : Services WordPress, MySQL, et Redis gérés via `docker-compose`.
*   **WordPress Préconfiguré** : Installation automatisée de WordPress au premier lancement.
*   **Plugins de Base Inclus (préparation pour installation)** :
    *   Advanced Custom Fields
    *   Yoast SEO (wordpress-seo)
    *   LiteSpeed Cache
    *   Contact Form 7
*   **WP-CLI** : Outil en ligne de commande pour WordPress inclus dans le conteneur WordPress.
*   **Composer** : Gestionnaire de dépendances PHP inclus pour les thèmes et plugins.
*   **Node.js & NVM** : Inclut NVM pour gérer Node.js (version 22.10.0 par défaut) pour le développement frontend.
*   **Redis** : Cache d'objets Redis préconfiguré pour améliorer les performances.
*   **msmtp** : Configuration pour l'envoi d'e-mails via un serveur SMTP externe.
*   **Personnalisation Facile** : Configuration via des variables d'environnement (`.env`).
*   **Développement et Production** : Comportement adaptable via la variable `WORDPRESS_ENV`.
*   **Thème Timber (préparation)** : Le script d'entrée est préparé pour faciliter l'intégration d'un thème basé sur Timber.
*   **Contenu Persistant** : Le dossier `wp-content` est mappé pour conserver vos thèmes, plugins et uploads.

## Prérequis

*   [Docker](https://docs.docker.com/get-docker/)
*   [Docker Compose](https://docs.docker.com/compose/install/) (généralement inclus avec Docker Desktop)

## Démarrage Rapide

1.  **Cloner le dépôt** (si ce n'est pas déjà fait) :
    ```bash
    git clone <votre-url-de-repo>
    cd <nom-du-dossier-du-projet>
    ```

2.  **Configurer l'environnement** :
    Copiez le fichier d'exemple `.env.example` vers `.env` :
    ```bash
    cp .env.example .env
    ```
    Modifiez le fichier `.env` avec vos propres informations (identifiants de base de données, URL du site, etc.). Assurez-vous que `WORDPRESS_HOST_PORT` correspond au port sur lequel vous souhaitez accéder à WordPress localement.

3.  **Lancer les conteneurs Docker** :
    ```bash
    docker-compose up -d
    ```
    Cette commande va construire les images (si nécessaire) et démarrer les services en arrière-plan.

4.  **Accéder à WordPress** :
    Ouvrez votre navigateur et allez à l'URL que vous avez définie dans `WORDPRESS_URL` (par exemple, `http://localhost:8080`). L'installation de WordPress devrait se finaliser automatiquement. Vous pourrez vous connecter à l'administration avec les identifiants `WORDPRESS_ADMIN_USER` et `WORDPRESS_ADMIN_PASSWORD` définis dans votre `.env`.

## Structure du Projet

```
.
├── docker-compose.yml        # Configuration des services Docker
├── .env.example              # Fichier d'exemple pour les variables d'environnement
├── LICENSE                   # Licence du projet (si présente)
├── README.md                 # Ce fichier
├── docker/
│   ├── Dockerfile--wordpress # Dockerfile pour l'image WordPress personnalisée
│   └── custom-entrypoint.sh  # Script d'initialisation pour le conteneur WordPress
└── wp-content/               # Dossier WordPress pour thèmes, plugins, uploads (mappé)
    ├── themes/
    ├── plugins/
    └── uploads/
```

## Variables d'Environnement

Les variables d'environnement sont gérées dans le fichier `.env`. Consultez `.env.example` pour la liste complète. Voici les plus importantes :

*   `WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`: Identifiants pour la base de données WordPress.
*   `MYSQL_ROOT_PASSWORD`: Mot de passe root pour le serveur MySQL.
*   `WORDPRESS_URL`: URL complète de votre site WordPress (ex: `http://localhost:8080`).
*   `WORDPRESS_TITLE`: Titre de votre site WordPress.
*   `WORDPRESS_ADMIN_USER`, `WORDPRESS_ADMIN_PASSWORD`, `WORDPRESS_ADMIN_EMAIL`: Identifiants pour le compte administrateur WordPress.
*   `CUSTOM_THEME_NAME`: Nom du slug pour votre thème personnalisé (ex: `my-custom-timber-theme`).
*   `WORDPRESS_ENV`: Définit l'environnement (`development` ou `production`).
    *   `development`: Mises à jour automatiques activées, modifications de fichiers autorisées.
    *   `production`: Mises à jour automatiques désactivées, modifications de fichiers bloquées.
*   `WORDPRESS_HOST_PORT`: Port sur la machine hôte pour accéder à WordPress (ex: `8080`).
*   `WORDPRESS_REDIS_HOST`, `WORDPRESS_REDIS_PORT`: Configuration pour le cache Redis.
*   `MSMTP_HOST`, `MSMTP_PORT`, `MSMTP_FROM`, `MSMTP_USER`, `MSMTP_PASSWORD`, etc.: Configuration pour l'envoi d'e-mails via msmtp.

## Développement

### Accéder au Conteneur WordPress

Pour exécuter des commandes à l'intérieur du conteneur WordPress (par exemple, WP-CLI ou Composer) :

```bash
docker-compose exec wordpress bash
```

### WP-CLI

Une fois dans le conteneur, vous pouvez utiliser WP-CLI. Par exemple, pour lister les plugins :

```bash
# S'assurer d'être dans le bon répertoire ou de spécifier --path
wp plugin list --path=/var/www/html --allow-root
```

### Composer

Composer est disponible globalement dans le conteneur WordPress. Si votre thème ou plugin utilise Composer :

```bash
# Naviguez vers le dossier de votre thème/plugin
cd /var/www/html/wp-content/themes/votre-theme
composer install
```

### Node.js / NVM

NVM et Node.js (version spécifiée dans `Dockerfile--wordpress`) sont installés. Vous pouvez les utiliser pour la compilation d'assets frontend.

```bash
# Dans le conteneur wordpress
nvm use default # Pour s'assurer d'utiliser la version par défaut de Node.js configurée
node -v
npm -v
# cd /var/www/html/wp-content/themes/votre-theme/path-vers-assets
# npm install
# npm run dev (ou autre script de build)
```

### Configuration des E-mails (msmtp)

Le conteneur WordPress est configuré pour envoyer des e-mails via `msmtp`. Les paramètres SMTP sont lus depuis les variables d'environnement `MSMTP_*`. Assurez-vous de les configurer correctement dans votre fichier `.env`. Les logs de msmtp sont disponibles dans `/tmp/msmtp.log` à l'intérieur du conteneur (configurable via `MSMTP_LOGFILE`).

### Cache Redis

Le cache d'objets Redis est configuré si `WORDPRESS_REDIS_HOST` est défini. Le script `custom-entrypoint.sh` ajoute `define( 'WP_CACHE', true );` à `wp-config.php`. Vous devrez installer et activer un plugin de cache Redis compatible (par exemple, "Redis Object Cache") dans WordPress pour que cela fonctionne pleinement.

## Personnalisation

### Thèmes et Plugins

Placez vos thèmes personnalisés dans `wp-content/themes/` et vos plugins dans `wp-content/plugins/`. Ces dossiers sont mappés depuis votre machine locale, donc les modifications sont directes.

Le script `custom-entrypoint.sh` est conçu pour faciliter l'utilisation d'un thème personnalisé (nommé via `CUSTOM_THEME_NAME`). Il peut également être étendu pour installer automatiquement des thèmes ou plugins spécifiques au démarrage.

### Dockerfile WordPress

Le fichier `docker/Dockerfile--wordpress` peut être modifié pour ajouter des dépendances PHP supplémentaires, des outils système, ou changer la version de Node.js. N'oubliez pas de reconstruire l'image après modification :

```bash
docker-compose build wordpress
# ou pour forcer la reconstruction et redémarrer :
docker-compose up -d --build
```

## Production

Pour un environnement de production :

1.  Définissez `WORDPRESS_ENV=production` dans votre fichier `.env`. Cela désactivera les modifications de fichiers et les mises à jour automatiques via l'interface d'administration de WordPress.
2.  Assurez-vous que toutes les informations sensibles (mots de passe, clés API) sont sécurisées et ne sont pas commitées si le `.env` est versionné (ce qui n'est pas recommandé pour les secrets).
3.  Configurez correctement votre serveur SMTP pour la production.
4.  Revoyez les configurations de sécurité et de performance.

## Dépannage

*   **Problèmes de permission sur `wp-content`** : Assurez-vous que les permissions du dossier `wp-content` sur votre machine hôte permettent au conteneur Docker d'écrire dedans. L'utilisateur dans le conteneur est `www-data` (UID 33 ou 82 selon l'image de base WordPress).
*   **MySQL ne démarre pas** : Vérifiez les logs du conteneur `db` avec `docker-compose logs db`.
*   **WordPress ne s'installe pas ou boucle au démarrage** : Vérifiez les logs du conteneur `wordpress` avec `docker-compose logs wordpress`. Le script `custom-entrypoint.sh` affiche des messages utiles.
*   **Emails non envoyés** : Vérifiez la configuration `MSMTP_*` dans `.env` et les logs de msmtp dans le conteneur (`/tmp/msmtp.log` par défaut, ou le chemin défini dans `MSMTP_LOGFILE`). Testez la configuration msmtp manuellement depuis le conteneur si besoin.
*   **Erreur "mysqladmin not found" dans les logs** : Le script `custom-entrypoint.sh` tente d'installer `default-mysql-client` si `mysqladmin` n'est pas trouvé. Si cela échoue, il peut y avoir un problème avec `apt-get update` ou la connectivité réseau à l'intérieur du conteneur au moment du build ou du premier démarrage.

## Contributions

Les contributions sont les bienvenues. Veuillez ouvrir une issue ou une pull request pour discuter des changements ou des améliorations.

## Auteur

Ce starter WordPress a été développé par [Lugh Web](https://lugh-web.fr).
