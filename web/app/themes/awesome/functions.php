<?php
/*==================================================
  include all files within a folder
==================================================*/
// Define the path to the includes directory
$includes_dir = get_template_directory() . '/inc/';

// Iterate through all PHP files in the includes directory and require them
foreach (glob($includes_dir . '*.php') as $file) {
    require_once $file;
}
/*----- end -----*/
