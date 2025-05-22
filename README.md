# WordPress Starter Kit avec Docker, Timber, Tailwind CSS et Terser

Ce projet est un kit de démarrage pour développer des sites WordPress modernes et performants en utilisant Docker. Il fournit un environnement de développement local complet, préconfiguré avec WordPress, MySQL, Redis, WP-CLI, Composer, Node.js (via NVM), Tailwind CSS v4, Terser, et msmtp pour l'envoi d'e-mails. Le projet met en place un thème enfant basé sur `timber-starter-theme` (le thème parent Timber officiel) et intègre une chaîne de compilation d'assets frontend.

## Fonctionnalités Principales

*   **Environnement Dockerisé Complet** : Services WordPress, MySQL, et Redis gérés via `docker compose`.
*   **WordPress Préconfiguré** : Installation automatisée de WordPress au premier lancement.
*   **Thème Enfant Timber Automatisé** :
    *   Création automatique d'un thème enfant basé sur `timber-starter-theme`.
    *   Le nom du thème enfant est personnalisable via la variable d'environnement `CUSTOM_THEME_NAME`.
    *   Le `composer.json` du thème parent est copié et les dépendances sont installées (`composer install`) dans le thème enfant.
*   **Intégration Frontend Moderne** :
    *   **Tailwind CSS v4** : Framework CSS utility-first pour un design rapide et personnalisé.
    *   **Terser** : Minificateur JavaScript pour optimiser les scripts.
    *   **npm scripts** : Scripts préconfigurés (`dev`, `build`) pour la compilation des assets (CSS et JS).
    *   Structure de fichiers pour les assets (`assets/css`, `assets/js`, `tailwind-input.css`).
*   **Outils de Développement Intégrés** :
    *   **WP-CLI** : Outil en ligne de commande pour WordPress inclus dans le conteneur WordPress.
    *   **Composer** : Gestionnaire de dépendances PHP inclus et utilisé pour le thème enfant.
    *   **Node.js & NVM** : Inclut NVM pour gérer Node.js (version 22.10.0 par défaut) pour le développement frontend.
*   **Optimisation et Utilitaires** :
    *   **Redis** : Cache d'objets Redis préconfiguré pour améliorer les performances de WordPress.
    *   **msmtp** : Configuration pour l'envoi d'e-mails via un serveur SMTP externe, facilitant les tests d'e-mails en développement.
*   **Personnalisation Facile** : Configuration via des variables d'environnement dans un fichier `.env`.
*   **Adapté aux Environnements de Développement et Production** : Comportement du site (mises à jour, modification de fichiers) adaptable via la variable `WORDPRESS_ENV`.
*   **Contenu Persistant** : Le dossier `wp-content` est mappé pour conserver vos thèmes, plugins et uploads entre les sessions Docker.
*   **Installation de Plugins (Optionnel)** : Le script d'entrée peut être facilement adapté pour installer et activer automatiquement une liste de plugins.

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
    Modifiez le fichier `.env` avec vos propres informations. Points clés à vérifier :
    *   `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_NAME`, `MYSQL_ROOT_PASSWORD` : Identifiants de la base de données.
    *   `WORDPRESS_URL` : URL complète de votre site WordPress local (ex: `http://localhost:8080`).
    *   `WORDPRESS_HOST_PORT` : Port sur votre machine hôte pour accéder à WordPress (doit correspondre à `WORDPRESS_URL`).
    *   `CUSTOM_THEME_NAME` : Nom (slug) de votre thème enfant (ex: `mon-super-theme`). Par défaut `starter`.
    *   `MSMTP_HOST`, `MSMTP_PORT`, etc. : Vos identifiants pour le serveur SMTP (Mailtrap est un bon choix pour le développement).

3.  **Lancer les conteneurs Docker** :
    À la racine du projet, exécutez :
    ```bash
    docker compose up -d --build
    ```
    L'option `--build` est recommandée au premier lancement ou après des modifications du `Dockerfile` ou du script `custom-entrypoint.sh`. Cette commande va construire les images et démarrer les services en arrière-plan.

4.  **Premier Lancement et Installation** :
    Lors du premier lancement, le script `custom-entrypoint.sh` va :
    *   Attendre que la base de données MySQL soit prête.
    *   Installer WordPress si ce n'est pas déjà fait.
    *   Configurer `wp-config.php` avec les informations du `.env` et les clés de sécurité.
    *   Configurer `msmtp` pour l'envoi d'e-mails.
    *   Cloner le thème `timber-starter-theme` s'il n'existe pas.
    *   Créer le thème enfant :
        *   Créer le dossier du thème enfant dans `wp-content/themes/`.
        *   Générer `style.css` et `functions.php` pour le thème enfant.
        *   Copier `composer.json` du parent et exécuter `composer install` dans le thème enfant.
        *   Initialiser `package.json`, installer les dépendances Node.js (`tailwindcss`, `terser`, etc.).
        *   Créer `tailwind-input.css` et les dossiers d'assets.
        *   Compiler les assets initiaux avec `npm run build`.
    *   Activer le thème enfant.
    *   Installer et activer les plugins listés (si configuré).
    *   Configurer les options WordPress pour l'environnement (`development` ou `production`).

5.  **Accéder à WordPress** :
    Ouvrez votre navigateur et allez à l'URL que vous avez définie dans `WORDPRESS_URL` (par exemple, `http://localhost:8080`).
    Connectez-vous à l'administration avec les identifiants `WORDPRESS_ADMIN_USER` et `WORDPRESS_ADMIN_PASSWORD` définis dans votre `.env`. Votre thème enfant devrait être actif.

## Structure du Projet

```
.
├── docker-compose.yml        # Configuration des services Docker (db, wordpress, redis)
├── .env.example              # Fichier d'exemple pour les variables d'environnement
├── .env                      # Fichier de configuration de l'environnement (ignoré par Git)
├── LICENSE                   # Licence du projet
├── README.md                 # Ce fichier
├── docker/
│   ├── Dockerfile--wordpress # Dockerfile pour l'image WordPress personnalisée
│   │                         # (installe PHP, NVM, Node.js, Composer, WP-CLI, msmtp, etc.)
│   └── custom-entrypoint.sh  # Script d'initialisation pour le conteneur WordPress
└── wp-content/               # Dossier WordPress pour thèmes, plugins, uploads (mappé)
    ├── themes/               # Contient le thème parent timber-starter-theme et votre thème enfant
    │   ├── timber-starter-theme/ # Thème parent (géré par le script)
    │   └── [CUSTOM_THEME_NAME]/  # Votre thème enfant (généré par le script)
    │       ├── assets/
    │       │   ├── css/
    │       │   │   └── tailwind.css  # CSS compilé par Tailwind
    │       │   └── js/
    │       │       ├── scripts.js      # Votre JS principal
    │       │       └── scripts.min.js  # JS minifié par Terser
    │       ├── node_modules/       # Dépendances Node.js (géré par npm)
    │       ├── vendor/             # Dépendances PHP (géré par Composer)
    │       ├── views/              # Fichiers Twig pour Timber (à créer)
    │       ├── composer.json       # Dépendances PHP du thème enfant
    │       ├── functions.php       # Fonctions du thème enfant
    │       ├── package.json        # Dépendances et scripts Node.js
    │       ├── style.css           # Informations du thème enfant
    │       └── tailwind-input.css  # Fichier source pour Tailwind CSS
    ├── plugins/                # Plugins WordPress
    └── uploads/                # Fichiers uploadés
```

## Variables d'Environnement

Configurez ces variables dans votre fichier `.env` :

*   **WordPress Database Settings**:
    *   `WORDPRESS_DB_HOST`: Hôte de la base de données (par défaut `db`, le nom du service MySQL dans Docker).
    *   `WORDPRESS_DB_USER`: Utilisateur de la base de données.
    *   `WORDPRESS_DB_PASSWORD`: Mot de passe de l'utilisateur.
    *   `WORDPRESS_DB_NAME`: Nom de la base de données.
    *   `MYSQL_ROOT_PASSWORD`: Mot de passe root pour le serveur MySQL.

*   **WordPress Site Settings**:
    *   `WORDPRESS_URL`: URL complète de votre site (ex: `http://localhost:8080`).
    *   `WORDPRESS_TITLE`: Titre de votre site WordPress.
    *   `WORDPRESS_ADMIN_USER`: Nom d'utilisateur de l'administrateur WordPress.
    *   `WORDPRESS_ADMIN_PASSWORD`: Mot de passe de l'administrateur.
    *   `WORDPRESS_ADMIN_EMAIL`: E-mail de l'administrateur.
    *   `WORDPRESS_TABLE_PREFIX`: Préfixe des tables WordPress (par défaut `wp_`).
    *   `CUSTOM_THEME_NAME`: Slug de votre thème enfant (ex: `mon-theme`). Par défaut `starter`.

*   **Environment Configuration**:
    *   `WORDPRESS_ENV`: `development` ou `production`.
        *   `development`: Mises à jour automatiques désactivées, modifications de fichiers autorisées, erreurs PHP affichées.
        *   `production`: Mises à jour automatiques désactivées, modifications de fichiers bloquées pour plus de sécurité.

*   **Docker Settings**:
    *   `WORDPRESS_HOST_PORT`: Port sur la machine hôte pour accéder à WordPress (ex: `8080`). Doit correspondre au port dans `WORDPRESS_URL`.

*   **Redis Settings**:
    *   `WORDPRESS_REDIS_HOST`: Hôte Redis (par défaut `redis`, le nom du service Redis dans Docker).
    *   `WORDPRESS_REDIS_PORT`: Port Redis (par défaut `6379`).

*   **SMTP (msmtp) Configuration**:
    *   `MSMTP_HOST`: Serveur SMTP (ex: `sandbox.smtp.mailtrap.io`).
    *   `MSMTP_PORT`: Port SMTP (ex: `587`).
    *   `MSMTP_FROM`: Adresse e-mail d'expédition par défaut.
    *   `MSMTP_AUTH`: Authentification (`on` ou `off`).
    *   `MSMTP_USER`: Nom d'utilisateur SMTP.
    *   `MSMTP_PASSWORD`: Mot de passe SMTP.
    *   `MSMTP_TLS`: Utiliser TLS (`on` ou `off`).
    *   `MSMTP_TLS_STARTTLS`: Utiliser STARTTLS (`on` ou `off`).
    *   `MSMTP_LOGFILE`: Chemin du fichier de log pour msmtp (ex: `/tmp/msmtp.log`).

## Développement

### Accéder au Conteneur WordPress

Pour exécuter des commandes à l'intérieur du conteneur WordPress (WP-CLI, Composer, NPM, etc.), utilisez `docker compose exec`. Le nom du service WordPress est défini dans `docker-compose.yml` (par défaut `wordpress`).

```bash
docker compose exec wordpress bash
```
Cela vous ouvrira un shell Bash à l'intérieur du conteneur. Le répertoire de travail par défaut est `/var/www/html`.

### Utilisation de WP-CLI

WP-CLI est installé et accessible globalement comme `wp`. Toutes les commandes WP-CLI doivent être exécutées avec l'option `--allow-root` car le serveur web tourne en tant que root dans ce conteneur.

Exemples (depuis l'intérieur du conteneur, ou préfixé par `docker compose exec wordpress`) :

*   Lister les plugins : `wp plugin list --allow-root`
*   Installer un plugin : `wp plugin install jetpack --activate --allow-root`
*   Vider le cache (si un plugin de cache est utilisé) : `wp cache flush --allow-root`
*   Accéder à la base de données : `wp db cli --allow-root`

### Gestion des dépendances PHP avec Composer

Composer est installé globalement. Votre thème enfant a son propre `composer.json` et ses dépendances dans son dossier `vendor/`.

Pour gérer les dépendances de votre thème enfant :

1.  Accédez au conteneur : `docker compose exec wordpress bash`
2.  Naviguez vers le dossier de votre thème enfant :
    ```bash
    cd wp-content/themes/${CUSTOM_THEME_NAME:-starter} 
    ```
    (Remplacez `${CUSTOM_THEME_NAME:-starter}` par le slug réel de votre thème si vous n'êtes pas sûr ou si la variable n'est pas disponible dans ce shell).
3.  Utilisez Composer :
    *   Ajouter une dépendance : `composer require mon-paquet/super-librairie`
    *   Mettre à jour les dépendances : `composer update`
    *   Installer les dépendances (si `vendor/` est manquant) : `composer install`

### Développement Frontend (Tailwind CSS & Terser)

Le thème enfant est configuré avec Tailwind CSS v4 et Terser.

1.  **Accédez au conteneur** : `docker compose exec wordpress bash`
2.  **Naviguez vers le dossier de votre thème enfant** :
    ```bash
    cd wp-content/themes/${CUSTOM_THEME_NAME:-starter}
    ```
3.  **Scripts NPM disponibles** (définis dans `package.json` du thème enfant) :
    *   **Mode développement (watch)** :
        ```bash
        npm run dev
        ```
        Cette commande surveille les modifications dans `tailwind-input.css` et vos fichiers de templates (`*.php`, `views/**/*.twig`, `assets/js/**/*.js`) et recompile `assets/css/tailwind.css` automatiquement.
    *   **Mode production (build)** :
        ```bash
        npm run build
        ```
        Cette commande compile et minifie `assets/css/tailwind.css` et minifie `assets/js/scripts.js` vers `assets/js/scripts.min.js`. Le script `custom-entrypoint.sh` exécute cette commande une fois lors de la création initiale du thème.

4.  **Fichiers clés pour le frontend** :
    *   `tailwind-input.css`: Fichier principal pour vos directives Tailwind, `@import "tailwindcss";`, et vos styles personnalisés `@layer base`, `@layer components`, `@layer utilities`.
    *   `tailwind.config.js`: (Optionnel, à créer si besoin de personnalisation avancée de Tailwind). Le script d'initialisation ne crée pas ce fichier par défaut, mais Tailwind v4 le prendra en compte s'il existe.
    *   `assets/js/scripts.js`: Votre fichier JavaScript principal.
    *   `assets/css/tailwind.css`: Fichier CSS généré par Tailwind (ne pas modifier directement).
    *   `assets/js/scripts.min.js`: Fichier JavaScript minifié (ne pas modifier directement).

    Assurez-vous que `functions.php` de votre thème enfant enqueue correctement `assets/css/tailwind.css` et `assets/js/scripts.min.js` (ou `scripts.js` en développement). Le `functions.php` généré par le script d'initialisation le fait déjà.

### Logs des Services Docker

Pour voir les logs d'un service spécifique (par exemple, `wordpress` ou `db`) :
```bash
docker compose logs wordpress
docker compose logs -f wordpress # Pour suivre les logs en temps réel
```

## Structure du Thème Enfant et Personnalisation

Le thème enfant est généré dans `wp-content/themes/[CUSTOM_THEME_NAME]/`.

*   **`style.css`**: Contient les informations de base du thème (Nom, Template, etc.).
*   **`functions.php`**:
    *   Enqueue les styles du thème parent (`timber-starter-theme`).
    *   Enqueue `tailwind.css` (compilé).
    *   Enqueue `scripts.min.js` (compilé et minifié).
    *   C'est ici que vous ajouterez la logique PHP de votre thème, les hooks, la configuration de Timber, etc.
*   **`views/`**: Ce dossier (à créer par vos soins) contiendra vos templates Twig utilisés par Timber. Par exemple : `views/base.twig`, `views/index.twig`, `views/single.twig`, etc.
*   **`tailwind-input.css`**: Modifiez ce fichier pour ajouter vos styles Tailwind ou des CSS personnalisés.
*   **`assets/js/scripts.js`**: Écrivez votre JavaScript ici.

## Configuration de l'envoi d'e-mails (msmtp)

Le conteneur WordPress est configuré pour utiliser `msmtp` pour envoyer des e-mails via un serveur SMTP externe. Ceci est utile pour tester les fonctionnalités d'e-mail de WordPress (notifications, formulaires de contact) en développement.

Configurez les variables `MSMTP_*` dans votre fichier `.env`. Mailtrap.io est un excellent service pour cela en développement, car il capture tous les e-mails envoyés sans les délivrer réellement.

Le fichier de configuration `/etc/msmtprc` est généré dynamiquement au démarrage du conteneur à partir de ces variables.

## Dépannage

*   **Problèmes de permission sur `wp-content`** : Assurez-vous que les permissions du dossier `wp-content` sur votre machine hôte permettent à Docker d'écrire dedans.
*   **Le site ne se charge pas** : Vérifiez les logs Docker (`docker compose logs wordpress` et `docker compose logs db`). Assurez-vous que `WORDPRESS_URL` et `WORDPRESS_HOST_PORT` sont correctement configurés.
*   **Erreurs WP-CLI** : N'oubliez pas `--allow-root`.
*   **Problèmes avec `npm` ou `composer` dans le conteneur** : Assurez-vous que Node.js et Composer sont correctement installés dans le Dockerfile et que les chemins sont corrects. Le `Dockerfile` fourni s'en charge.
*   **"MySQL is unavailable"** : Le script `custom-entrypoint.sh` attend MySQL, mais si des problèmes persistent, vérifiez les logs du conteneur `db`.
*   **Changements dans `tailwind-input.css` non reflétés** : Assurez-vous que `npm run dev` est en cours d'exécution dans le conteneur du thème enfant, ou exécutez `npm run build` manuellement. Vérifiez également que votre navigateur ne met pas en cache l'ancien CSS.

## Commandes Utiles Docker Compose

*   Démarrer les services en arrière-plan : `docker compose up -d`
*   Arrêter les services : `docker compose down`
*   Arrêter et supprimer les volumes (attention, supprime la base de données !) : `docker compose down -v`
*   Voir les logs : `docker compose logs <nom-du-service>`
*   Reconstruire les images : `docker compose build` ou `docker compose up -d --build`
*   Lister les conteneurs en cours : `docker compose ps`

## Contribuer

Les suggestions et contributions sont les bienvenues. Veuillez ouvrir une issue ou une pull request.

## Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

Le concept de base de ce starter WordPress a été initialement développé par Lugh Web (https://lugh-web.fr).
