<?php

/**
 * Configuration overrides for WP_ENV === 'development'
 */

use Roots\WPConfig\Config;

use function Env\env;

Config::define('SAVEQUERIES', true);
Config::define('WP_DEBUG', true);
Config::define('WP_DEBUG_DISPLAY', true);
Config::define('WP_DEBUG_LOG', env('WP_DEBUG_LOG') ?? true);
Config::define('WP_DISABLE_FATAL_ERROR_HANDLER', true);
Config::define('SCRIPT_DEBUG', true);
Config::define('DISALLOW_INDEXING', true);

ini_set('display_errors', '1');

// Enable plugin and theme updates and installation from the admin
Config::define('DISALLOW_FILE_MODS', false);

// Force default mailer for WP Mail Plugin
Config::define('WPMS_MAILER', env('WPMS_MAILER') ?? 'smtp');
// Define the SMTP host. If the environment variable WPMS_SMTP_HOST is set, it will be used; otherwise, it defaults to 'localhost'.
Config::define('WPMS_SMTP_HOST', env('WPMS_SMTP_HOST') ?? 'mailpit');
// Define the SMTP port. If the environment variable WPMS_SMTP_PORT is set, it will be used; otherwise, it defaults to 1025 (commonly used for testing).
Config::define('WPMS_SMTP_PORT', env('WPMS_SMTP_PORT') ?? 1025);
// Define the SMTP user. If the environment variable WPMS_SMTP_USER is set, it will be used; otherwise, it defaults to null (no user).
Config::define('WPMS_SMTP_USER', env('WPMS_SMTP_USER') ?? null);
// Define the SMTP password. If the environment variable WPMS_SMTP_PASS is set, it will be used; otherwise, it defaults to null (no password).
Config::define('WPMS_SMTP_PASS', env('WPMS_SMTP_PASS') ?? null);

// Monolog
Config::define('LOG_LEVEL', 'WARNING');
Config::define('LOG_TRACE', true);
