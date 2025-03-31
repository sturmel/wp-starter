# wp-starter

A WordPress starter project using Docker Compose for local development.

## Prerequisites

*   Docker
*   Docker Compose

## Getting Started

1.  Clone the repository:

    ```bash
    git clone <repository_url>
    cd wp-starter
    ```

2.  Start the containers:

    ```bash
    docker-compose up --build
    ```

3.  Access the WordPress site in your browser at `http://localhost:8101`.

## Configuration

The project uses the following environment variables:

*   `MYSQL_ROOT_PASSWORD`: The password for the MySQL root user.
*   `MYSQL_USER`: The MySQL user for WordPress.
*   `MYSQL_PASSWORD`: The password for the WordPress MySQL user.
*   `MYSQL_DATABASE`: The name of the MySQL database for WordPress.

These variables are defined in the `docker-compose.yml` file.

## Development

The `html` directory is mounted as a volume to the `/var/www/html` directory in the `wordpress` container. This allows you to edit the WordPress files locally and see the changes reflected in the container.

## WP-CLI

WP-CLI is installed in the `wordpress` container and can be used to manage the WordPress installation.

To access WP-CLI, you can use the following command:

```bash
docker-compose exec wordpress wp <command>
```

## Plugins

The following plugins are installed by default:

*   Advanced Custom Fields
*   Yoast SEO
*   Wordfence
*   Contact Form 7
*   Complianz GDPR
*   W3 Total Cache
*   All-in-One WP Migration

The `Hello Dolly` plugin is removed during the installation process.