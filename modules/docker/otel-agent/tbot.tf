resource "docker_image" "tbot" {
  name          = var.tbot_image.name
  pull_triggers = [var.tbot_image.sha256_digest]
}

locals {
  tbot_tunnel_listen_host = "0.0.0.0"
  tbot_tunnel_listen_port = 4318

  tbot_config = templatefile("${path.module}/tbot.yaml.tftpl", {
    proxy_server      = var.teleport_proxy_address
    join_token        = var.teleport_join_token
    signoz_app_name   = var.signoz_app_name
    tunnel_listen_uri = "tcp://${local.tbot_tunnel_listen_host}:${local.tbot_tunnel_listen_port}"
  })
}

resource "docker_volume" "tbot_storage" {
  name = "${var.docker_name_prefix}otel_agent_tbot_storage"
}

resource "docker_container" "tbot" {
  image   = docker_image.tbot.image_id
  name    = "${var.docker_name_prefix}otel_agent_tbot"
  restart = "always"

  command = ["start", "-c", "/etc/tbot.yaml"]

  upload {
    file    = "/etc/tbot.yaml"
    content = local.tbot_config
  }

  volumes {
    volume_name    = docker_volume.tbot_storage.name
    container_path = "/var/lib/tbot"
  }

  network_mode = "bridge"

  networks_advanced {
    name    = docker_network.otel_agent.name
    aliases = ["tbot"]
  }
}
