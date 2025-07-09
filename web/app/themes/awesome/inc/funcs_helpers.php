<?php

use function Env\env;

function wpse_get_partial($template_name, $data = []) {
    $template = locate_template($template_name . '.php', false);
  
    if (!$template) {
      return;
    }
  
    if ($data) {
      extract($data);
    }
  
    include($template);
}

function get_hashed_asset_url($filename) {
    static $manifest = null;

    if ($manifest === null) {
        $manifest_path = get_template_directory() . '/assets/build/rev-manifest.json';
        if (!file_exists($manifest_path)) {
            $manifest = [];
        } else {
            $manifest = json_decode(file_get_contents($manifest_path), true);
            if (!is_array($manifest)) {
                $manifest = [];
            }
        }
    }

    if (!isset($manifest[$filename])) {
      return '';
    }

    $base_url = rtrim(env('ASSETS_URL'), '/');
    $asset_path = ltrim($manifest[$filename], '/');

    return $base_url . '/' . $asset_path;
}