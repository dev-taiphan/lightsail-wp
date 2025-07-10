locals {
  keys = [
    "DB_NAME",
    "DB_USER",
    "DB_PASSWORD",
    "WP_ENV",
    "WP_HOME",
    "WP_SITEURL",
    "AUTH_KEY",
    "SECURE_AUTH_KEY",
    "LOGGED_IN_KEY",
    "NONCE_KEY",
    "AUTH_SALT",
    "SECURE_AUTH_SALT",
    "LOGGED_IN_SALT",
    "NONCE_SALT",
    "WPMS_SMTP_HOST",
    "WPMS_SMTP_PORT",
    "WPMS_SMTP_USER",
    "WPMS_SMTP_PASS",
    "RECAPTCHA_SITE_KEY",
    "RECAPTCHA_SECRET_KEY",
    "DB_HOST",
    "DD_API_KEY",
    "BASIC_AUTH_USER",
    "BASIC_AUTH_PASSWORD"
  ]
}

resource "random_password" "passwords" {
  count  = length(local.keys)
  length = 8
}

resource "aws_ssm_parameter" "parameters" {
  count  = length(local.keys)
  name   = "/${var.service_name}/${var.env}/${local.keys[count.index]}"
  type   = "SecureString"
  value  = random_password.passwords[count.index].result
  key_id = "alias/aws/ssm"

  lifecycle {
    ignore_changes = [value]
  }
}
