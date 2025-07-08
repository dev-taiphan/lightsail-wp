output "secrets_used" {
  description = "Secrets loaded from SSM"
  value       = local.secrets_map
}
