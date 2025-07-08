data "aws_ssm_parameters_by_path" "all_secrets" {
  path            = "/${var.lcs_service_name}/${var.env}/"
  recursive       = true
  with_decryption = true
}

locals {
  secrets_map = {
    for p in data.aws_ssm_parameters_by_path.all_secrets.parameters :
    basename(p.name) => p.value
  }
}

resource "aws_lightsail_container_service_deployment" "this" {
  service_name = var.lcs_service_name

  container {
    name  = var.lcs_container_name
    image = var.image_uri

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
