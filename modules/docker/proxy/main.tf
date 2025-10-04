terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.11.0"
    }
  }
}

data "docker_registry_image" "proxy" {
  name = "nginxproxy/nginx-proxy:1.8.0"
}

resource "docker_image" "proxy" {
  name          = data.docker_registry_image.proxy.name
  pull_triggers = [data.docker_registry_image.proxy.sha256_digest]
}

resource "docker_network" "proxy" {
  name       = "proxy"
  attachable = true
}

module "certificates" {
  source   = "../../cloudflare/certificate"
  hostname = each.value
  for_each = var.certificate_hostnames
}

resource "docker_container" "proxy" {
  //noinspection HILUnresolvedReference
  image   = docker_image.proxy.image_id
  name    = "proxy"
  restart = "always"

  ports {
    internal = 443
    external = 443
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.proxy.id
  }

  volumes {
    container_path = "/tmp/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }

  dynamic "upload" {
    for_each = module.certificates
    content {
      file    = "/etc/nginx/certs/${upload.value["hostname"]}.crt"
      content = upload.value["certificate"]
    }
  }

  dynamic "upload" {
    for_each = module.certificates
    content {
      file    = "/etc/nginx/certs/${upload.value["hostname"]}.key"
      content = upload.value["private_key"]
    }
  }
}
