data "aws_ssm_parameters_by_path" "all" {
  path            = "/${var.lcs_service_name}/${var.env}/"
  recursive       = true
  with_decryption = true
}

data "aws_ssm_parameter" "each_param" {
  for_each        = toset(data.aws_ssm_parameters_by_path.all.names)
  name            = each.value
  with_decryption = true
}

locals {
  secrets_map = {
    for key, param in data.aws_ssm_parameter.each_param :
    basename(key) => param.value
  }
}

resource "aws_lightsail_container_service_deployment" "this" {
  service_name = var.lcs_service_name

  container {
    name  = var.lcs_container_name
    image = "REPLACE_ECR_IMAGE"

    ports = {
      80 = "HTTP"
    }

    environment = local.secrets_map
  }

  public_endpoint {
    container_name = var.lcs_container_name
    container_port = 80
  }
}
