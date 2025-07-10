data "aws_ssm_parameters_by_path" "all" {
  path            = "/${var.service_name}/${var.env}/"
  recursive       = true
  with_decryption = true
}

data "aws_ssm_parameter" "each_param" {
  for_each        = toset(data.aws_ssm_parameters_by_path.all.names)
  name            = each.value
  with_decryption = true
}

locals {
  skip_keys = [
    "CONTAINER_DEFINITION",
    "BASIC_AUTH_USER",
    "BASIC_AUTH_PASSWORD"
  ]

  environment = {
    for key, param in data.aws_ssm_parameter.each_param :
    basename(key) => param.value
    if !(contains(local.skip_keys, basename(key)))
  }
}

locals {
  container_json = jsonencode({
    containers = {
      ("${var.service_name}-wp") = {
        image = "REPLACE_ECR_IMAGE"
        ports = {
          "80" = "HTTP"
        }
        environment = local.environment
      }
    }
    publicEndpoint = {
      containerName = "${var.service_name}-wp"
      containerPort = 80
    }
  })
}

resource "aws_ssm_parameter" "container_definition" {
  name  = "/${var.service_name}/${var.env}/CONTAINER_DEFINITION"
  type  = "SecureString"
  value = local.container_json
  overwrite = true
}
