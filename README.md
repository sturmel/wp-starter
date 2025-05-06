# WordPress Docker Environment

This project provides a Dockerized environment for running a WordPress instance with a Timber-based theme and several common plugins.

## Prerequisites

*   Docker ([Install Docker](https://docs.docker.com/get-docker/))
*   Docker Compose ([Install Docker Compose](https://docs.docker.com/compose/install/))

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <your-repository-url>
    cd <your-repository-directory>
    ```

2.  **Configure your environment:**
    *   Copy the example environment file:
        ```bash
        cp .env.example .env
        ```
    *   Edit the `.env` file and customize the variables as needed. Pay special attention to:
        *   `WORDPRESS_DB_PASSWORD`, `MYSQL_ROOT_PASSWORD`, `WORDPRESS_ADMIN_PASSWORD`: Set strong, unique passwords.
        *   `WORDPRESS_URL`: Set this to the URL you will use to access your WordPress site (e.g., `http://localhost:8080`).
        *   `WORDPRESS_HOST_PORT`: Ensure this matches the host port you want to use (e.g., `8080` for `http://localhost:8080`).

3.  **Build and run the Docker containers:**
    ```bash
    docker compose up -d
    ```
    This command will build the images if they don't exist and start the WordPress and database services in detached mode.

4.  **Access WordPress:**
    *   Once the containers are running, open your web browser and navigate to the `WORDPRESS_URL` you configured in your `.env` file (e.g., `http://localhost:8080`).
    *   You should see the WordPress installation screen or your site if it's already installed. The `custom-entrypoint.sh` script handles the WordPress core installation, Timber theme setup, and plugin activations on the first run.

## Included Features

*   **WordPress:** The latest stable version of WordPress.
*   **Timber Theme:** The [Timber Starter Theme](https://timber.github.io/docs/getting-started/setup/) is installed and activated by default. This allows for more flexible and maintainable theme development using Twig templates.
*   **Essential Plugins:** The following plugins are installed and activated automatically:
    *   Advanced Custom Fields
    *   WordPress SEO (Yoast SEO)
    *   LiteSpeed Cache
    *   Contact Form 7
*   **WP-CLI:** The WordPress Command Line Interface is available within the WordPress container for easy management.
*   **Composer:** PHP dependency manager, used here primarily for installing the Timber theme.

## Customization

### Modifying Environment Variables

You can change WordPress settings, database credentials, and other configurations by editing the `.env` file. After making changes, you may need to restart the containers:

```bash
docker compose down
docker compose up -d
```

For some changes, like the database name or user after initial setup, you might need to manually adjust WordPress configuration or re-run the installation process (potentially by removing the `wp-content` and database volumes if you want a fresh start).

### Adding/Removing Plugins or Themes

*   **Plugins:**
    *   You can add new plugins by modifying the `PLUGINS_TO_INSTALL` array in the `custom-entrypoint.sh` script.
    *   Alternatively, you can install plugins through the WordPress admin dashboard or using WP-CLI:
        ```bash
        docker compose exec wordpress wp plugin install <plugin-slug> --activate --allow-root
        ```
*   **Themes:**
    *   The Timber Starter Theme is installed via Composer in `custom-entrypoint.sh`. You can adapt this to install a different Composer-based theme.
    *   For standard WordPress themes, you can place them in the `wp-content/themes` directory (which is volume-mounted) and activate them via the WordPress admin or WP-CLI.

### Custom Entrypoint Script

The `custom-entrypoint.sh` script handles the initial setup. You can modify this script to:
*   Install different versions of themes or plugins.
*   Add custom WP-CLI commands to run on startup.
*   Change default WordPress options.

## Directory Structure

```
.
├── .env.example          # Example environment variables
├── custom-entrypoint.sh  # Custom script for WordPress setup, theme/plugin installation
├── docker-compose.yml    # Docker Compose configuration
└── wp-content/           # WordPress content directory (themes, plugins, uploads)
    ├── themes/           # WordPress themes (Timber starter theme will be installed here)
    └── plugins/          # WordPress plugins (will be populated by the entrypoint script)
    └── mu-plugins/       # WordPress must-use plugins
    └── uploads/          # WordPress uploads
```

The `wp-content` directory is mounted as a volume, so your themes, plugins, and uploads will persist even if you stop and remove the containers (as long as the volume is not explicitly deleted).

## Troubleshooting

*   **Permissions:** If you encounter permission issues with `wp-content`, ensure the user running Docker has write permissions or adjust the ownership within the container (e.g., `chown -R www-data:www-data /var/www/html/wp-content`). The `custom-entrypoint.sh` attempts to handle this for Composer-installed themes.
*   **MySQL Connection Issues:** Verify your `WORDPRESS_DB_HOST`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, and `WORDPRESS_DB_NAME` in the `.env` file match the MySQL service configuration in `docker-compose.yml`. The entrypoint script includes a wait loop for MySQL to be ready.
*   **Check Logs:**
    ```bash
    docker compose logs wordpress
    docker compose logs db
    ```

## Stopping the Environment

To stop the containers:
```bash
docker compose down
```

To stop and remove the volumes (this will delete your WordPress data, including the database, themes, and plugins unless they are in your local `wp-content` directory and you've configured volumes accordingly):
```bash
docker compose down -v
```
