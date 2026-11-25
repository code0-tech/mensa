terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.7.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.28.1"
    }
  }
}

data "docker_registry_image" "proxy" {
  name = "nginxproxy/nginx-proxy:1.11.6"
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
  source    = "../../cloudflare/certificate"
  hostnames = [each.value]
  for_each  = var.certificate_hostnames
}

resource "docker_container" "proxy" {
  //noinspection HILUnresolvedReference
  image   = docker_image.proxy.image_id
  name    = "proxy"
  restart = "always"

  env = [
    # CVE-2026-123633 & CVE-2026-123007
    "ENABLE_HTTP2=false"
  ]

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
      file    = "/etc/nginx/certs/${upload.value["hostnames"][0]}.crt"
      content = upload.value["certificate"]
    }
  }

  dynamic "upload" {
    for_each = module.certificates
    content {
      file    = "/etc/nginx/certs/${upload.value["hostnames"][0]}.key"
      content = upload.value["private_key"]
    }
  }

  dynamic "upload" {
    for_each = var.hostname_config_overrides
    content {
      file    = "/etc/nginx/vhost.d/${upload.value["hostname"]}"
      content = upload.value["config"]
    }
  }

  # CVE-2026-123633 & CVE-2026-123007
  upload {
    file = "/etc/nginx/conf.d/00-catchall.conf"
    content = <<-EOF
      server {
          listen 443 ssl default_server;
          server_name _;
          http2 off;
          ssl_reject_handshake on;
      }
    EOF
  }
}
