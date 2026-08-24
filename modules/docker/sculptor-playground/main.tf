terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.5.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.2.1"
    }
  }
}

variable "hostname" {
  type = string
}

variable "playground_frame_ancestors" {
  type = string
}

variable "docker_proxy_network_id" {
  type = string
}

data "docker_registry_image" "sculptor" {
  name = "ghcr.io/code0-tech/reticulum/ci-builds/sculptor:0.0.0-experimental-2781831788-b99c1d6592ea4c7204a746e2ab46858e50b6968f-ce"
}

resource "docker_image" "sculptor" {
  name          = data.docker_registry_image.sculptor.name
  pull_triggers = [data.docker_registry_image.sculptor.sha256_digest]
}

resource "docker_container" "sculptor" {
  //noinspection HILUnresolvedReference
  image   = docker_image.sculptor.image_id
  name    = "sculptor-playground"
  restart = "always"

  env = [
    "VIRTUAL_HOST=${var.hostname}",
    "VIRTUAL_PORT=3000",
    "VIRTUAL_PATH=~^/(_next|api|playground)",
    "PLAYGROUND_MOCK_DIR=/mock",
    "PLAYGROUND_FRAME_ANCESTORS=${var.playground_frame_ancestors}"
  ]

  upload {
    file = "/mock/flows.json"
    source = "${path.module}/files/flows.json"
    source_hash = filebase64sha256("${path.module}/files/flows.json")
  }

  dynamic "upload" {
    for_each = fileset("${path.module}/files", "modules/*.json")
    content {
      file = "/mock/${upload.value}"
      source = "${path.module}/files/${upload.value}"
      source_hash = filebase64sha256("${path.module}/files/${upload.value}")
    }
  }

  networks_advanced {
    name = var.docker_proxy_network_id
  }
}
