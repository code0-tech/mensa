terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

resource "random_password" "action_token" {
  length = 32
  special = false
}

resource "docker_image" "image" {
  name          = var.image.name
  pull_triggers = [var.image.sha256_digest]
}

resource "docker_container" "container" {
  //noinspection HILUnresolvedReference
  image   = docker_image.image.image_id
  name    = "${var.docker_name_prefix}${var.identifier}-action"
  restart = "unless-stopped"

  env = concat([
    "HERCULES_AQUILA_URL=${var.aquila_url}",
    "HERCULES_AUTH_TOKEN=${random_password.action_token.result}",
    "HERCULES_ACTION_ID=${var.identifier}",
  ], var.additional_envs)

  dynamic "networks_advanced" {
    for_each = compact(var.docker_networks)
    content {
      name = networks_advanced.value
    }
  }
}
