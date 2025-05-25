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
