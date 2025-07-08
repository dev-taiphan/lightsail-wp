output "container_definition" {
  description = "The container definition JSON"
  value       = aws_ssm_parameter.container_definition.value
  sensitive = true
}
