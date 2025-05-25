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
        $js_file_name_relative = '/dev_build/scripts.js';

        if (!file_exists(get_stylesheet_directory() . $css_file_name_relative)) {
            $css_file_name_relative = '/assets/css/styles.css';
        }

        if (!file_exists(get_stylesheet_directory() . $js_file_name_relative)) {
            $js_file_name_relative = '/assets/js/scripts.js';
        }
    } else {
        $css_file_name_relative = '/dist/styles.min.css';
        $js_file_name_relative = '/dist/scripts.min.js';
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
