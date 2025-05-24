#!/bin/bash

echo "[ManageThemes] Managing themes installation and activation..."

# Function to ensure composer install for a theme
ensure_composer_install() {
    local theme_path="$1"
    local theme_name="$2"
    if [ -d "${theme_path}" ]; then
        if [ ! -d "${theme_path}/vendor" ]; then
            echo "[ManageThemes] Vendor directory not found in ${theme_name} at ${theme_path}. Running composer install..."
            if [ -f "${theme_path}/composer.json" ]; then
                if command -v composer &> /dev/null; then
                    (cd "${theme_path}" && composer install --no-dev --prefer-dist)
                    echo "[ManageThemes] Composer install completed for ${theme_name}."
                else
                    echo "[ManageThemes WARNING] Composer not found. Cannot run composer install for ${theme_name}."
                fi
            else
                echo "[ManageThemes WARNING] composer.json not found in ${theme_name} at ${theme_path}. Cannot run composer install."
            fi
        else
            echo "[ManageThemes] Vendor directory already exists in ${theme_name} at ${theme_path}."
        fi
    else
        echo "[ManageThemes] Theme ${theme_name} not found at ${theme_path}. Skipping composer check."
    fi
}

# Ensure composer install for starter theme
ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}"

if [ "$CURRENT_ENV" = "development" ]; then
    echo "[ManageThemes] In development mode, ensuring Timber starter theme is present and custom theme is installed and active."

    # Install Timber starter theme if not present
    if [ ! -d "${STARTER_THEME_PATH}" ]; then
        echo "[ManageThemes] Timber Starter Theme not found at ${STARTER_THEME_PATH}. Installing..."
        mkdir -p "${THEMES_PATH}"
        if cd "${THEMES_PATH}"; then
            composer create-project upstatement/timber-starter-theme "${STARTER_THEME_SLUG}" --no-dev --prefer-dist
            echo "[ManageThemes] Timber Starter Theme installed in ${STARTER_THEME_PATH}."
            ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}" 
            cd "$OLDPWD"
        else
            echo "[ManageThemes ERROR] Could not cd to ${THEMES_PATH}. Cannot install Timber Starter Theme."
        fi
    else
        echo "[ManageThemes] Timber Starter Theme already exists at ${STARTER_THEME_PATH}."
        ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}" 
    fi

    # Create custom child theme if not present
    if [ ! -d "${CUSTOM_THEME_PATH}" ]; then
        echo "[ManageThemes] Child theme ${CUSTOM_THEME_SLUG} not found at ${CUSTOM_THEME_PATH}."
        if [ -d "${STARTER_THEME_PATH}" ]; then
            echo "[ManageThemes] Creating child theme ${CUSTOM_THEME_SLUG} for parent ${STARTER_THEME_SLUG}..."
            mkdir -p "${CUSTOM_THEME_PATH}"

            # Create style.css
            echo "[ManageThemes] Creating style.css for ${CUSTOM_THEME_SLUG}..."
            cat << EOF_STYLE > "${CUSTOM_THEME_PATH}/style.css"
/*
 * Theme Name: ${CUSTOM_THEME_SLUG}
 * Template: ${STARTER_THEME_SLUG}
 * Description: Child theme built upon the Timber starter theme, leveraging the Twig templating engine for enhanced separation of concerns and cleaner code. It integrates Advanced Custom Fields (ACF) for flexible content management and utilizes Tailwind CSS for a utility-first styling approach. The development workflow is powered by npm for frontend package management and webpack for modern build processing. It includes GSAP for animations, Terser for JavaScript minification, and BrowserSync for live development, ensuring optimized performance and maintainability. This setup promotes a modern, efficient, and scalable WordPress development experience.
 * Version: 1.0
 * Author: Lugh Web
 * Author URI: https://lugh-web.fr
*/
EOF_STYLE

            # Create inc directory and PHP files
            mkdir -p "${CUSTOM_THEME_PATH}/inc"
            
            echo "[ManageThemes] Creating performance.php for ${CUSTOM_THEME_SLUG}..."
            cat << 'EOF_PERFORMANCE' > "${CUSTOM_THEME_PATH}/inc/performance.php"
<?php
add_action('wp_enqueue_scripts', function () {
    wp_dequeue_style('wp-block-library');
    wp_dequeue_style('wp-block-library-theme');
    wp_dequeue_style('global-styles');
    wp_dequeue_style('classic-theme-styles');
}, 20);

function disable_emojis()
{
    remove_action('wp_head', 'print_emoji_detection_script', 7);
    remove_action('admin_print_scripts', 'print_emoji_detection_script');
    remove_action('wp_print_styles', 'print_emoji_styles');
    remove_action('admin_print_styles', 'print_emoji_styles');
    remove_filter('the_content_feed', 'wp_staticize_emoji');
    remove_filter('comment_text_rss', 'wp_staticize_emoji');
    remove_filter('wp_mail', 'wp_staticize_emoji_for_email');
    add_filter('tiny_mce_plugins', 'disable_emojis_tinymce');
    add_filter('wp_resource_hints', 'disable_emojis_remove_dns_prefetch', 10, 2);
}
add_action('init', 'disable_emojis');

function disable_emojis_tinymce($plugins)
{
    if (is_array($plugins)) {
        return array_diff($plugins, array('wpemoji'));
    } else {
        return array();
    }
}

function disable_emojis_remove_dns_prefetch($urls, $relation_type)
{
    if ('dns-prefetch' == $relation_type) {
        $emoji_svg_url_bit = 'https://s.w.org/images/core/emoji/';
        foreach ($urls as $key => $url) {
            if (strpos($url, $emoji_svg_url_bit) !== false) {
                unset($urls[$key]);
            }
        }
    }
    return $urls;
}

remove_action('wp_head', 'rest_output_link_wp_head', 10);
EOF_PERFORMANCE
            
            echo "[ManageThemes] Creating security.php for ${CUSTOM_THEME_SLUG}..."
            cat << 'EOF_SECURITY' > "${CUSTOM_THEME_PATH}/inc/security.php"
<?php
// Security related functions and hooks

/**
 * Disable XML-RPC interface.
 */
add_filter('xmlrpc_enabled', '__return_false');

/**
 * Remove WordPress version number from various places.
 */
function remove_wordpress_version()
{
    return '';
}
add_filter('the_generator', 'remove_wordpress_version'); // General generator tag

// Also remove from RSS feeds (duplicate of the above, but good to be explicit)
add_filter('the_generator', function () {
    return '';
});

/**
 * Remove version numbers from script and style URLs.
 */
function remove_version_from_scripts_styles($src)
{
    if (strpos($src, 'ver=')) {
        $src = remove_query_arg('ver', $src);
    }
    return $src;
}
add_filter('style_loader_src', 'remove_version_from_scripts_styles', 9999);
add_filter('script_loader_src', 'remove_version_from_scripts_styles', 9999);

/**
 * Disable File Editor in WordPress admin.
 * It's best to also set this in wp-config.php if possible.
 */
if (!defined('DISALLOW_FILE_EDIT')) {
    define('DISALLOW_FILE_EDIT', true);
}

/**
 * Attempt to remove X-Powered-By header.
 * Effectiveness depends on server configuration.
 */
if (function_exists('header_remove')) {
    @header_remove('X-Powered-By'); // Suppress errors if it fails
}

/**
 * Remove unnecessary header links for security.
 */
remove_action('wp_head', 'wp_generator'); // WordPress generator tag (covered by remove_wordpress_version but good to have)
remove_action('wp_head', 'wlwmanifest_link'); // Windows Live Writer Manifest Link
remove_action('wp_head', 'rsd_link'); // Really Simple Discovery Link
// remove_action('wp_head', 'wp_shortlink_wp_head'); // Shortlink (consider if you use it)
// remove_action('wp_head', 'wp_oembed_add_discovery_links', 10); // oEmbed discovery links (if not using oEmbeds)
// remove_action('template_redirect', 'rest_output_link_header', 11, 0); // REST API link from HTTP headers (if REST API is not public)
EOF_SECURITY

            echo "[ManageThemes] Creating functions.php for ${CUSTOM_THEME_SLUG}..."
            cat << 'EOF_FUNCTIONS' > "${CUSTOM_THEME_PATH}/functions.php"
<?php
require_once(get_stylesheet_directory() . '/inc/security.php');
require_once(get_stylesheet_directory() . '/inc/performance.php');

add_action('wp_enqueue_scripts', 'theme_enqueue_styles_scripts');
function theme_enqueue_styles_scripts()
{
    wp_enqueue_style('parent-style', get_template_directory_uri() . '/style.css');
    wp_enqueue_style(
        'child-style',
        get_stylesheet_directory_uri() . '/style.css',
        array('parent-style'),
        wp_get_theme()->get('Version')
    );

    $wordpress_env = getenv('WORDPRESS_ENV');

    if ($wordpress_env === 'development') {
        $css_file_name_relative = '/dev_build/styles.css';
        $js_file_name_relative = '/dev_build/main.js';
    } else {
        $css_file_name_relative = '/dist/styles.min.css';
        $js_file_name_relative = '/dist/main.min.js';
    }

    $theme_css_path = get_stylesheet_directory() . $css_file_name_relative;
    if (file_exists($theme_css_path)) {
        wp_enqueue_style(
            'tailwind-style',
            get_stylesheet_directory_uri() . $css_file_name_relative,
            array('child-style'),
            filemtime($theme_css_path)
        );
    }

    $theme_js_path = get_stylesheet_directory() . $js_file_name_relative;
    if (file_exists($theme_js_path)) {
        wp_enqueue_script(
            'child-scripts',
            get_stylesheet_directory_uri() . $js_file_name_relative,
            array(),
            filemtime($theme_js_path),
            true
        );
    }
}

add_filter('script_loader_tag', 'add_type_attribute_to_script', 10, 3);
function add_type_attribute_to_script($tag, $handle, $src)
{
    if ('child-scripts' === $handle) {
        $tag = '<script type="module" src="' . esc_url($src) . '" id="' . $handle . '-js"></script>';
    }
    return $tag;
}

function hide_editor()
{
    if (!is_admin()) {
        return;
    }
    $screen = get_current_screen();
    if ($screen && $screen->id === 'page') {
        $postId = $_GET['post'] ?? $_POST['post_ID'] ?? null;
        if ($postId) {
            $templateFile = get_post_meta($postId, '_wp_page_template', true);
            $targetTemplates = array();
            if (in_array($templateFile, $targetTemplates)) {
                remove_post_type_support('page', 'editor');
            }
        }
    }
}
add_action('load-page.php', 'hide_editor');

function custom_navigation()
{
    register_nav_menu('main_menu', __('Menu principal'));
    register_nav_menu('footer_menu_legal', __('Menu footer Legal'));
    register_nav_menu('footer_menu_social', __('Menu footer Social'));
}
add_action('init', 'custom_navigation');

add_filter('use_block_editor_for_post', '__return_false');
add_filter('use_widgets_block_editor', '__return_false');

add_filter('timber/context', function ($context) {
    $context['main_menu'] = Timber\Timber::get_menu('main_menu');
    $context['footer_menu_legal'] = Timber\Timber::get_menu('footer_menu_legal');
    $context['footer_menu_social'] = Timber\Timber::get_menu('footer_menu_social');
    $upload_dir_info = wp_upload_dir();
    $context['uploads_base_url'] = $upload_dir_info['baseurl'];

    return $context;
});
EOF_FUNCTIONS

            echo "[ManageThemes] Creating .gitignore for ${CUSTOM_THEME_SLUG}..."
            cat << EOF_GITIGNORE > "${CUSTOM_THEME_PATH}/.gitignore"
node_modules/
package-lock.json
vendor/
dist/
dev_build/
EOF_GITIGNORE

            echo "[ManageThemes] Setting up Node.js environment and build tools in ${CUSTOM_THEME_PATH}..."
            ( 
                cd "${CUSTOM_THEME_PATH}" || { echo "[ManageThemes ERROR] Failed to cd into ${CUSTOM_THEME_PATH}"; exit 1; }

                # Verify Node.js and npm are available
                echo "[ManageThemes] Verifying Node.js and npm availability..."
                if ! command -v node &> /dev/null; then
                    echo "[ManageThemes ERROR] Node.js not found in PATH. Checking NVM..."
                    if [ -s "$NVM_DIR/nvm.sh" ]; then
                        echo "[ManageThemes] Loading NVM..."
                        . "$NVM_DIR/nvm.sh"
                        nvm use default 2>/dev/null || nvm use node 2>/dev/null
                    fi
                fi

                if ! command -v node &> /dev/null; then
                    echo "[ManageThemes ERROR] Node.js still not available. Cannot proceed with npm setup."
                    exit 1
                fi

                if ! command -v npm &> /dev/null; then
                    echo "[ManageThemes ERROR] npm not found. Cannot proceed with dependency installation."
                    exit 1
                fi

                echo "[ManageThemes] Node.js version: $(node --version)"
                echo "[ManageThemes] npm version: $(npm --version)"

                echo "[ManageThemes] Creating package.json for ${CUSTOM_THEME_SLUG}..."
                cat << EOF_PACKAGE > ./package.json
{
  "name": "${CUSTOM_THEME_SLUG}",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1",
    "dev": "webpack --mode=development --watch",
    "build": "webpack --mode=production"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "description": "",
  "devDependencies": {
    "@babel/core": "^7.27.1",
    "@babel/preset-env": "^7.27.2",
    "@tailwindcss/forms": "^0.5.10",
    "@tailwindcss/postcss": "^4.1.7",
    "@tailwindcss/typography": "^0.5.16",
    "autoprefixer": "^10.4.21",
    "babel-loader": "^10.0.0",
    "browser-sync": "^2.29.3",
    "browser-sync-webpack-plugin": "^2.3.0",
    "concurrently": "^9.1.2",
    "css-loader": "^7.1.2",
    "mini-css-extract-plugin": "^2.9.2",
    "postcss": "^8.5.3",
    "postcss-import": "^16.1.0",
    "postcss-loader": "^8.1.1",
    "tailwindcss": "^4.1.7",
    "terser": "^5.39.2",
    "terser-webpack-plugin": "^5.3.14",
    "webpack": "^5.99.9",
    "webpack-cli": "^6.0.1",
    "webpack-dev-server": "^5.2.1"
  },
  "dependencies": {
    "gsap": "^3.13.0"
  }
}
EOF_PACKAGE

                echo "[ManageThemes] Installing npm dependencies..."
                echo "[ManageThemes] Current working directory: $(pwd)"
                echo "[ManageThemes] Listing files in current directory:"
                ls -la
                echo "[ManageThemes] Node.js version: $(node --version)"
                echo "[ManageThemes] npm version: $(npm --version)"
                echo "[ManageThemes] npm config list:"
                npm config list
                echo "[ManageThemes] Starting npm install with verbose logging..."
                
                if npm install --verbose 2>&1 | tee npm-install.log; then
                    echo "[ManageThemes] npm dependencies installed successfully."
                    rm -f npm-install.log
                else
                    echo "[ManageThemes ERROR] npm install failed. Full error log:"
                    echo "=================================="
                    cat npm-install.log
                    echo "=================================="
                    echo "[ManageThemes] Checking npm cache and permissions..."
                    echo "npm cache dir: $(npm config get cache)"
                    echo "npm prefix: $(npm config get prefix)"
                    echo "Current user: $(whoami)"
                    echo "Current user ID: $(id)"
                    echo "[ManageThemes] Attempting to continue without dependencies..."
                    # Don't exit here, just log the error and continue
                fi

                echo "[ManageThemes] Creating browsersync.config.js for ${CUSTOM_THEME_SLUG}..."
                cat << EOF_BROWSERSYNC_CONFIG > ./browsersync.config.js
module.exports = {
  proxy: "localhost:${WORDPRESS_HOST_PORT}",
  files: [
    "**/*.css",
    "**/*.php",
    "**/*.twig",
    "**/*.js"
  ],
  port: 3000,
  notify: false,
  ui: {
    port: 3001
  }
};
EOF_BROWSERSYNC_CONFIG

                echo "[ManageThemes] Creating webpack.config.js for ${CUSTOM_THEME_SLUG}..."
                cat << 'EOF_WEBPACK_CONFIG' > ./webpack.config.js
const path = require('path');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const BrowserSyncPlugin = require('browser-sync-webpack-plugin');

module.exports = (env, argv) => {
  const isProduction = argv.mode === 'production';
  const outputPath = isProduction ? 'dist' : 'dev_build';

  return {
    entry: {
      main: './assets/js/scripts.js',
      styles: './assets/css/main.css'
    },
    output: {
      path: path.resolve(__dirname, outputPath),
      filename: isProduction ? '[name].min.js' : '[name].js',
      clean: true,
    },
    mode: isProduction ? 'production' : 'development',
    devtool: isProduction ? false : 'source-map',
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader',
            options: {
              presets: ['@babel/preset-env']
            }
          }
        },
        {
          test: /\.css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            {
              loader: 'postcss-loader',
              options: {
                postcssOptions: {
                  plugins: [
                    require('postcss-import'),
                    require('@tailwindcss/postcss'),
                    require('autoprefixer'),
                  ],
                },
              },
            },
          ],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: isProduction ? '[name].min.css' : '[name].css',
      }),
      ...(argv.mode === 'development' ? [
        new BrowserSyncPlugin({
          proxy: 'localhost:8080',
          files: [
            '**/*.php',
            '**/*.twig',
            outputPath + '/**/*.css',
            outputPath + '/**/*.js'
          ],
          port: 3000,
          notify: false,
          ui: {
            port: 3001
          }
        })
      ] : [])
    ],
    optimization: {
      minimizer: isProduction ? [
        new TerserPlugin({
          terserOptions: {
            compress: true,
            mangle: true,
          },
        }),
      ] : [],
    },
    watch: argv.mode === 'development',
    watchOptions: {
      aggregateTimeout: 300,
      poll: 1000,
      ignored: /node_modules/,
    },
  };
};
EOF_WEBPACK_CONFIG

                echo "[ManageThemes] Creating postcss.config.js for ${CUSTOM_THEME_SLUG}..."
                cat << 'EOF_POSTCSS_CONFIG' > ./postcss.config.js
module.exports = {
  plugins: [
    require('postcss-import'),
    require('@tailwindcss/postcss'),
    require('autoprefixer'),
  ],
};
EOF_POSTCSS_CONFIG

                echo "[ManageThemes] Creating Tailwind CSS v4 input file..."
                mkdir -p ./assets/css
                cat << 'EOF_TAILWIND_INPUT_CSS' > ./assets/css/main.css
/* Import Tailwind's base, components, and utilities for v4 */
@import "tailwindcss";

/* Explicitly define content paths here for Tailwind v4 */
@content '../../views/**/*.twig';
@content '../../*.php';
@content '../js/**/*.js';

/* Custom base styles */
@layer base {}

/* Custom component styles */
@layer components {}

@layer utilities {}

/* Custom theme variables for Tailwind v4 */
@theme {}
EOF_TAILWIND_INPUT_CSS

                echo "[ManageThemes] Creating JavaScript directory and initial script file..."
                mkdir -p ./assets/js
                cat << 'EOF_SCRIPTS_JS' > ./assets/js/scripts.js
import { gsap } from 'gsap';

addEventListener('DOMContentLoaded', function() {
   console.log('🔧 Webpack entry file loaded');
});
EOF_SCRIPTS_JS

            ) 
            echo "[ManageThemes] Node.js environment and build tools setup complete for ${CUSTOM_THEME_SLUG}."

        else
            echo "[ManageThemes ERROR] Cannot create child theme as parent theme ${STARTER_THEME_SLUG} does not exist at ${STARTER_THEME_PATH}."
        fi
    else
        echo "[ManageThemes] Custom theme ${CUSTOM_THEME_SLUG} already exists at ${CUSTOM_THEME_PATH}."
    fi

    # Activate custom theme
    if [ -d "${CUSTOM_THEME_PATH}" ]; then
        CUSTOM_THEME_STATUS=$(wp theme status "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root --field=status 2>/dev/null || echo "not-installed")
        if [ "$CUSTOM_THEME_STATUS" != "active" ]; then
            echo "[ManageThemes] Activating theme: ${CUSTOM_THEME_SLUG}"
            if wp theme activate "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[ManageThemes] Theme ${CUSTOM_THEME_SLUG} activated successfully."
            else
                echo "[ManageThemes WARNING] Failed to activate theme ${CUSTOM_THEME_SLUG}."
            fi
        else
            echo "[ManageThemes] Theme ${CUSTOM_THEME_SLUG} is already active."
        fi
    else
        echo "[ManageThemes WARNING] Custom theme ${CUSTOM_THEME_SLUG} not found. Cannot activate."
    fi

else  
    echo "[ManageThemes] In production mode. Ensuring custom theme is active if it exists, otherwise Timber starter, otherwise default."
    ensure_composer_install "${STARTER_THEME_PATH}" "${STARTER_THEME_SLUG}"

    ACTIVE_THEME=$(wp theme list --status=active --field=name --path="${WP_PATH}" --allow-root 2>/dev/null || echo "")
    if [ -z "$ACTIVE_THEME" ] || [ "$ACTIVE_THEME" != "$CUSTOM_THEME_SLUG" ]; then
        echo "[ManageThemes WARNING] Active theme is '$ACTIVE_THEME'. Attempting to activate ${CUSTOM_THEME_SLUG} if present."
        if [ -d "${CUSTOM_THEME_PATH}" ]; then
            if wp theme activate "${CUSTOM_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[ManageThemes] Theme ${CUSTOM_THEME_SLUG} activated in production."
            else
                echo "[ManageThemes ERROR] Failed to activate ${CUSTOM_THEME_SLUG} in production. Trying ${STARTER_THEME_SLUG}."
                if [ -d "${STARTER_THEME_PATH}" ]; then
                    if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                        echo "[ManageThemes] Theme ${STARTER_THEME_SLUG} activated."
                    else
                        echo "[ManageThemes ERROR] Failed to activate ${STARTER_THEME_SLUG}. Manual intervention may be required."
                    fi
                else
                    DEFAULT_THEME=$(wp theme list --field=name --path="${WP_PATH}" --allow-root | head -n 1)
                    if [ -n "$DEFAULT_THEME" ]; then
                         echo "[ManageThemes WARNING] ${STARTER_THEME_SLUG} not found. Attempting to activate default theme: $DEFAULT_THEME"
                         if wp theme activate "$DEFAULT_THEME" --path="${WP_PATH}" --allow-root; then
                            echo "[ManageThemes] Default theme $DEFAULT_THEME activated."
                         else
                            echo "[ManageThemes ERROR] Failed to activate default theme $DEFAULT_THEME in production. Manual intervention required."
                         fi
                    else
                        echo "[ManageThemes ERROR] No themes found to activate in production. WordPress may not function correctly."
                    fi
                fi
            fi
        elif [ -d "${STARTER_THEME_PATH}" ]; then
             echo "[ManageThemes WARNING] Custom theme ${CUSTOM_THEME_SLUG} not found. Attempting to activate ${STARTER_THEME_SLUG}."
            if wp theme activate "${STARTER_THEME_SLUG}" --path="${WP_PATH}" --allow-root; then
                echo "[ManageThemes] Theme ${STARTER_THEME_SLUG} activated."
            else
                echo "[ManageThemes ERROR] Failed to activate ${STARTER_THEME_SLUG}. Manual intervention may be required."
            fi
        else
            DEFAULT_THEME=$(wp theme list --field=name --path="${WP_PATH}" --allow-root | head -n 1)
            if [ -n "$DEFAULT_THEME" ]; then
                 echo "[ManageThemes WARNING] Neither custom nor starter theme found. Attempting to activate default theme: $DEFAULT_THEME"
                 if wp theme activate "$DEFAULT_THEME" --path="${WP_PATH}" --allow-root; then
                    echo "[ManageThemes] Default theme $DEFAULT_THEME activated."
                 else
                    echo "[ManageThemes ERROR] Failed to activate default theme $DEFAULT_THEME in production. Manual intervention required."
                 fi
            else
                echo "[ManageThemes ERROR] No themes found to activate in production. WordPress may not function correctly."
            fi
        fi
    else
        echo "[ManageThemes] Active theme in production: $ACTIVE_THEME."
    fi
fi 

echo "[ManageThemes] Theme management complete."
