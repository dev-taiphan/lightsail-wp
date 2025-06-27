<?php
function add_inline_env_styles() {
    if (defined('WP_ENV') && (WP_ENV === 'prd' || WP_ENV === 'production')) {
        $custom_css = '
            #wpadminbar { background-color: #e34234; }
        ';
    } else {
        $custom_css = '
            #wpadminbar { background-color: #118ab2; }
        ';
    }
    wp_add_inline_style('admin-bar', $custom_css);
}

add_action('wp_enqueue_scripts', 'add_inline_env_styles');
add_action('admin_enqueue_scripts', 'add_inline_env_styles');