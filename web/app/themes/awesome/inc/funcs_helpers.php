<?php

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