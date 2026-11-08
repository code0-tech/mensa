resource "docker_image" "otel_collector" {
  name          = var.otel_collector_image.name
  pull_triggers = [var.otel_collector_image.sha256_digest]
}

locals {
  otlp_export_endpoint = "http://tbot:${local.tbot_tunnel_listen_port}"

  otel_config = templatefile("${path.module}/otel-collector.yaml.tftpl", {
    hostmetrics_scrape_interval = var.hostmetrics_scrape_interval
    otlp_export_endpoint        = local.otlp_export_endpoint
    environment                 = var.environment
    resource_attributes         = var.resource_attributes
  })
}

resource "docker_container" "otel_collector" {
  image   = docker_image.otel_collector.image_id
  name    = "${var.docker_name_prefix}otel_agent_collector"
  restart = "always"

  command = ["--config", "/etc/otelcol/config.yaml"]

  upload {
    file    = "/etc/otelcol/config.yaml"
    content = local.otel_config
  }

  volumes {
    host_path      = "/"
    container_path = "/hostfs"
    read_only      = true
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.otel_agent.name
  }

  dynamic "networks_advanced" {
    for_each = toset(var.docker_additional_network_ids)

    content {
      name = networks_advanced.value
    }
  }

  depends_on = [
    docker_container.tbot,
  ]
}
