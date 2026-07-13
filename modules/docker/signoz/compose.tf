locals {
  override_env_content = <<ENV
PROXY_NETWORK=${var.proxy_network}
SIGNOZ_VIRTUAL_HOST=${var.hostname}
SIGNOZ_TOKENIZER_JWT_SECRET=${random_password.jwt_secret.result}
POSTGRES_PASSWORD=${random_password.postgres_password.result}
ENV
}

resource "terraform_data" "env_file" {
  triggers_replace = [
    sha256(local.override_env_content),
    filesha256("${path.module}/pours/deployment/compose.yaml"),
    filesha256("${path.module}/docker-compose.override.yml"),
  ]

  provisioner "local-exec" {
    command = "cat <<'ENVEOF' > ${path.module}/override.env\n${local.override_env_content}\nENVEOF"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/override.env"
  }
}

resource "docker_compose" "signoz" {
  project_name = "signoz"
  env_files    = ["${path.module}/override.env"]
  config_paths = ["${path.module}/pours/deployment/compose.yaml", "${path.module}/docker-compose.override.yml"]

  depends_on = [
    terraform_data.env_file,
    docker_container.config_writer,
  ]

  lifecycle {
    replace_triggered_by = [
      terraform_data.env_file,
      docker_container.config_writer,
    ]
  }
}
