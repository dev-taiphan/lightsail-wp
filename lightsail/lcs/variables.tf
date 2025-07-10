variable "env" {
  type        = string
  description = "The deployment environment (e.g., dev1, dev2, prd)"
}

variable "service_name" {
  type        = string
  description = "The name of the service being deployed"
}
