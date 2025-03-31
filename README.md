# Bedrock/Sage WordPress Starter with Docker

This project provides a Docker-based development environment for a WordPress site using Bedrock and Sage.

## Prerequisites

*   Docker
*   Docker Compose

## Setup

1.  **Clone the repository:**

    ```bash
    git clone <your-repository-url>
    cd <your-repository-directory>
    ```

2.  **Start the Docker containers:**

    ```bash
    docker-compose up -d
    ```

    This will build and start the following containers:

    *   `wordpress_db`: MySQL database for WordPress.
    *   `wordpress-bedrock`: WordPress application running Bedrock.

3.  **Access the WordPress site:**

    Open your web browser and navigate to `http://localhost:8101`.

## Key Components

*   **Bedrock:** A modern WordPress boilerplate with improved folder structure, dependency management (Composer), and environment configuration (`.env`).
*   **Sage:** A WordPress starter theme featuring a modern development workflow, including Blade templating, Sass, and Webpack (or Vite).
*   **Docker:** A containerization platform for creating isolated and reproducible development environments.
*   **Docker Compose:** A tool for defining and managing multi-container Docker applications.

## Directory Structure

*   `.`: Root directory containing `docker-compose.yml` and other configuration files.
*   `html`: WordPress root directory.  This is where Bedrock is installed.
*   `html/web/app/themes/sage`: Sage theme directory.
*   `docker`: Contains Docker-related files.
    *   `docker/wordpress/Dockerfile`: Dockerfile for building the WordPress image.
    *   `docker/wordpress/entrypoint.sh`: Entrypoint script for initializing the WordPress container.
    *   `docker/wordpress/apache/sites-enabled`: Apache configuration files.
    *   `docker/wordpress/php/php.ini`: PHP configuration file.

## Configuration

*   **`docker-compose.yml`:** Defines the services, networks, and volumes for the Docker application.  You can adjust port mappings, environment variables, and resource limits in this file.
*   `.env`:** (Created by `entrypoint.sh`) Contains environment-specific settings for Bedrock, such as database credentials and WordPress URLs.  **Important:** Do not commit this file to version control.
*   `html/web/app/themes/sage/config/app.php` : Sage configuration file.

## Development Workflow

1.  **Access the WordPress container:**

    ```bash
    docker exec -it wordpress-bedrock bash
    ```

2.  **Navigate to the Sage theme directory:**

    ```bash
    cd /var/www/html/web/app/themes/sage
    ```

3.  **Install Node dependencies:**

    ```bash
    npm install
    ```

4.  **Start the development server:**

    ```bash
    npm run dev
    ```

    Or, if you're using Vite:

     ```bash
    npm run dev
    ```

5.  **Develop your theme:**

    Make changes to the theme files in the `html/web/app/themes/sage` directory. The development server will automatically rebuild the assets as you make changes.

6.  **Build for production:**

    ```bash
    npm run build
    ```

    Or, if you're using Vite:

     ```bash
    npm run build
    ```

    This will generate optimized assets in the `html/web/app/themes/sage/public/build` directory.

## Troubleshooting

*   **"The asset manifest \[/var/www/html/web/app/themes/sage/public/manifest.json] cannot be found."**

    *   Ensure that you have run `npm run build` (or `yarn build`) in the `sage` theme directory.
    *   Verify that the `manifest.json` file exists in the `html/web/app/themes/sage/public/build` directory.
    *   Double-check your Sage configuration to ensure it's correctly pointing to the `manifest.json` file.
    *   If you're using Vite, ensure the `base` option in `vite.config.js` is correctly configured.

## Additional Notes

*   The `entrypoint.sh` script automates the Bedrock installation process and creates the `.env` file.
*   The Dockerfile installs essential PHP extensions, Composer, WP-CLI, and Node.js.
*   You can customize the Apache configuration by modifying the files in the `docker/wordpress/apache/sites-enabled` directory.
*   You can customize the PHP configuration by modifying the `docker/wordpress/php/php.ini` file.
