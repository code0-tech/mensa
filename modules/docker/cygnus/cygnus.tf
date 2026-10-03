resource "docker_image" "cygnus" {
  name          = var.cygnus_image.name
  pull_triggers = [var.cygnus_image.sha256_digest]
}

resource "random_password" "payload_secret" {
  length = 32
}

resource "random_password" "payload_user_password" {
  length = 32
}

resource "random_password" "actions_import_secret" {
  length = 64
}

data "gitlab_project_variable" "ga_measurement_id" {
  project = "code0-tech/secret-manager"
  key     = "CYGNUS_NEXT_PUBLIC_GA_MEASUREMENT_ID"
}

data "gitlab_project_variable" "smtp_host" {
  project = "code0-tech/secret-manager"
  key     = "CYGNUS_SMTP_HOST"
}

data "gitlab_project_variable" "smtp_user" {
  project = "code0-tech/secret-manager"
  key     = "CYGNUS_SMTP_USER"
}

data "gitlab_project_variable" "smtp_pass" {
  project = "code0-tech/secret-manager"
  key     = "CYGNUS_SMTP_PASS"
}

data "gitlab_project_variable" "contact_to_email" {
  project = "code0-tech/secret-manager"
  key     = "CYGNUS_CONTACT_TO_EMAIL"
}

locals {
  cygnus_env = [
    # Cygnus
    "NODE_ENV=production",
    "PAYLOAD_SECRET=${random_password.payload_secret.result}",
    "PAYLOAD_USER_PASS=${random_password.payload_user_password.result}",
    "DATABASE_URL=postgresql://cygnus:${random_password.db.result}@${docker_container.postgres.hostname}:5432/payload",
    "HOSTNAME=0.0.0.0",
    "GA_MEASUREMENT_ID=${sensitive(data.gitlab_project_variable.ga_measurement_id.value)}",
    "SERVER_URL=https://${var.web_urls[0]}",
    "ACTIONS_IMPORT_SECRET=${random_password.actions_import_secret.result}",

    # Cygnus SMTP
    "SMTP_HOST=${data.gitlab_project_variable.smtp_host.value}",
    "SMTP_PORT=465",
    "SMTP_USER=${data.gitlab_project_variable.smtp_user.value}",
    "SMTP_PASS=${data.gitlab_project_variable.smtp_pass.value}",
    "CONTACT_FROM_EMAIL=${data.gitlab_project_variable.smtp_user.value}",
    "CONTACT_TO_EMAIL=${data.gitlab_project_variable.contact_to_email.value}",

    # Proxy
    "VIRTUAL_HOST=${join(",", var.web_urls)}"
  ]
}

resource "docker_volume" "cygnus_media" {
  name = "${var.docker_name_prefix}cygnus_media"
}

resource "docker_container" "cygnus" {
  image   = docker_image.cygnus.image_id
  name    = "${var.docker_name_prefix}cygnus_cygnus"
  restart = "always"

  env = concat(local.cygnus_env, var.additional_envs)

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.cygnus.name
  }

  dynamic "networks_advanced" {
    for_each = compact([var.docker_additional_network_id])

    content {
      name = networks_advanced.value
    }
  }

  dynamic "ports" {
    for_each = compact([var.http_port])

    content {
      internal = 3000
      external = ports.value
      ip       = var.bind_ip
    }
  }

  volumes {
    volume_name    = docker_volume.cygnus_media.name
    container_path = "/cygnus/.next/standalone/media"
  }

  lifecycle {
    replace_triggered_by = [
      docker_container.postgres.id
    ]
  }
}
