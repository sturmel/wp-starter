# WordPress Starter Project

This project provides a basic WordPress setup using Docker and Docker Compose. It includes a WordPress instance and a MySQL database, configured for easy local development.

## Prerequisites

-   Docker
-   Docker Compose

## Getting Started

1.  Clone the repository:

    ```bash
    git clone <repository_url>
    cd wp-starter
    ```

2.  Run Docker Compose to start the services:

    ```bash
    docker-compose up -d
    ```

3.  Access the WordPress site in your browser at `http://localhost:8101`.

## Configuration

The WordPress and database configurations are managed through environment variables in the `docker-compose.yml` file.

### Environment Variables

-   `MYSQL_ROOT_PASSWORD`: Root password for the MySQL database.
-   `MYSQL_USER`: User for the WordPress database.
-   `MYSQL_PASSWORD`: Password for the WordPress database user.
-   `MYSQL_DATABASE`: Name of the WordPress database.
-   `WORDPRESS_DB_NAME`: WordPress database name.
-   `WORDPRESS_DB_USER`: WordPress database user.
-   `WORDPRESS_DB_PASSWORD`: WordPress database password.
-   `WORDPRESS_DB_HOST`: WordPress database host.
-   `WORDPRESS_ADMIN_USER`: WordPress admin username.
-   `WORDPRESS_ADMIN_PASSWORD`: WordPress admin password.
-   `WORDPRESS_ADMIN_EMAIL`: WordPress admin email.
-   `WORDPRESS_SITE_URL`: WordPress site URL.
-   `WORDPRESS_SITE_NAME`: WordPress site name.

## Included Components

-   **WordPress:** The latest version of WordPress, configured with `wp-cli`.
-   **MySQL:** MySQL 8.0 as the database server.
-   **php:** php 8.3

## Volumes

-   `./html:/var/www/html`: Mounts the `./html` directory on your host machine to the WordPress document root in the container.
-   `./docker/wordpress/apache/sites-enabled:/etc/apache2/sites-enabled`: Mounts custom Apache site configurations.
-   `./docker/wordpress/php/php.ini:/usr/local/etc/php/conf.d/extra-php-config.ini`: Mounts custom PHP configurations.
-   `wordpress_db:/var/lib/mysql`: Docker volume for persistent MySQL data storage.

## Customization

-   **Themes and Plugins:** Place your custom themes and plugins in the `./html/wp-content/themes` and `./html/wp-content/plugins` directories, respectively.
-   **Apache Configuration:** Modify the Apache configuration files in the `./docker/wordpress/apache/sites-enabled` directory.
-   **PHP Configuration:** Adjust the PHP settings in the `./docker/wordpress/php/php.ini` file.
-   **Dockerfile:** The `docker/wordpress/Dockerfile` contains the instructions to build the WordPress image. You can customize it to install additional PHP extensions, tools, or dependencies.

## Entrypoint Script

The `docker/wordpress/entrypoint.sh` script is executed when the WordPress container starts. It handles the following tasks:

-   Checks if the `html` directory is empty.
-   If empty, downloads and installs WordPress using `wp-cli`.
-   Creates a `wp-config.php` file.
-   Installs and activates several plugins.
-   Starts the Apache server.

## Docker Compose

The `docker-compose.yml` file defines the services, networks, and volumes for the WordPress application. It simplifies the process of building and running the containers.

## Notes

-   The MySQL root password and other sensitive information should be stored securely in a production environment.
-   This setup is intended for local development and testing purposes.