data "docker_registry_image" "cygnus" {
  name = "ghcr.io/code0-tech/cygnus:1056"
}

resource "docker_image" "cygnus" {
  name          = data.docker_registry_image.cygnus.name
  pull_triggers = [data.docker_registry_image.cygnus.sha256_digest]
}

resource "random_password" "payload_secret" {
  length = 32
}

resource "random_password" "payload_user_password" {
  length = 32
}

locals {
  cygnus_env = [
    # Cygnus
    "NODE_ENV=production",
    "PAYLOAD_SECRET=${random_password.payload_secret.result}",
    "PAYLOAD_USER_PASS=${random_password.payload_user_password.result}",
    "DATABASE_URL=postgresql://cygnus:${random_password.db.result}@${docker_container.postgres.hostname}:5432/payload",
    "HOSTNAME=0.0.0.0",

    # Proxy
    "VIRTUAL_HOST=${var.web_url}"
  ]
}

resource "docker_container" "cygnus" {
  image   = docker_image.cygnus.image_id
  name    = "cygnus_cygnus"
  restart = "always"

  env = local.cygnus_env

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.cygnus.name
  }

  networks_advanced {
    name = var.docker_proxy_network_id
  }

  lifecycle {
    replace_triggered_by = [
      docker_container.postgres.id
    ]
  }
}
