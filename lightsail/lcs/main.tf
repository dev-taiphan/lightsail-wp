data "aws_ssm_parameters_by_path" "all" {
  path            = "/${var.app_name}/${var.env}/"
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

  secrets_map = {
    for key, param in data.aws_ssm_parameter.each_param :
    basename(key) => param.value
    if !(contains(local.skip_keys, basename(key)))
  }
}

locals {
  container_json = jsonencode({
    containers = {
      (var.lcs_container_name) = {
        image = "REPLACE_ECR_IMAGE"
        ports = {
          "80" = "HTTP"
        }
        environment = local.secrets_map
      }
    }
    publicEndpoint = {
      containerName = var.lcs_container_name
      containerPort = 80
    }
  })
}

resource "aws_ssm_parameter" "container_definition" {
  name  = "/${var.app_name}/${var.env}/CONTAINER_DEFINITION"
  type  = "String"
  value = local.container_json
  overwrite = true
}
