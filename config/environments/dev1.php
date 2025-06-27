<?php

/**
 * Configuration overrides for WP_ENV === 'staging'
 */

use Roots\WPConfig\Config;

/**
 * You should try to keep staging as close to production as possible. However,
 * should you need to, you can always override production configuration values
 * with `Config::define`.
 *
 * Example: `Config::define('WP_DEBUG', true);`
 * Example: `Config::define('DISALLOW_FILE_MODS', false);`
 */

Config::define('DISALLOW_INDEXING', true);

// AWS S3
Config::define('AWS_S3_URL', 'https://dev1.brandrevalue.com/assets/wp-content/themes/bring');
Config::define('ASSETS_URL', 'https://dev1.brandrevalue.com/assets/wp-content/themes/bring');

// WP MAIL SMTP
Config::define('WPMS_MAIL_FROM', 'info@dev1.brandrevalue.jp');
Config::define('WPMS_MAIL_FROM_FORCE', true);
Config::define('WPMS_MAIL_FROM_NAME', '高額ブランド買取 BRAND REVALUE');
Config::define('WPMS_MAIL_FROM_NAME_FORCE', false);
Config::define('WPMS_SSL', 'tls');
Config::define('WPMS_SMTP_AUTH', true);
Config::define('WPMS_SMTP_AUTOTLS', true);
Config::define('WPMS_MAILER', 'smtp');

// Monolog
Config::define('LOG_LEVEL', 'WARNING');
Config::define('LOG_TRACE', true);
