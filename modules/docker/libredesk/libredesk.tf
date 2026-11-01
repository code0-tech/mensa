data "docker_registry_image" "libredesk" {
  name = "libredesk/libredesk:v2.9.2"
}

resource "docker_image" "libredesk" {
  name          = data.docker_registry_image.libredesk.name
  pull_triggers = [data.docker_registry_image.libredesk.sha256_digest]
}

resource "random_password" "encryption_key" {
  length  = 16
  special = false
}

resource "random_password" "system_user_password" {
  length = 32
}

locals {
  # Libredesk requires a 32-char encryption key; derive a hex-safe 32-char
  # string from the generated random value.
  encryption_key = substr(sha256(random_password.encryption_key.result), 0, 32)

  config_toml = templatefile("${path.module}/config.toml.tftpl", {
    encryption_key = local.encryption_key
    db_host        = docker_container.postgres.name
    db_user        = "libredesk"
    db_password    = random_password.db.result
    db_name        = "libredesk"
    redis_address  = "${docker_container.redis.name}:6379"
  })

  libredesk_env = [
    "LIBREDESK_SYSTEM_USER_PASSWORD=${random_password.system_user_password.result}",

    # Proxy
    "VIRTUAL_PORT=9000",
  ]
}

resource "docker_volume" "uploads" {
  name = "${var.docker_name_prefix}libredesk_uploads"
}

resource "docker_container" "libredesk" {
  image   = docker_image.libredesk.image_id
  name    = "${var.docker_name_prefix}libredesk_libredesk"
  restart = "unless-stopped"

  env = concat(local.libredesk_env, var.additional_envs)

  command = [
    "sh", "-c",
    "./libredesk --install --idempotent-install --yes --config /libredesk/config.toml && ./libredesk --upgrade --yes --config /libredesk/config.toml && ./libredesk --config /libredesk/config.toml"
  ]

  upload {
    file    = "/libredesk/config.toml"
    content = local.config_toml
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.libredesk.name
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
      internal = 9000
      external = ports.value
      ip       = var.bind_ip
    }
  }

  volumes {
    volume_name    = docker_volume.uploads.name
    container_path = "/libredesk/uploads"
  }

  depends_on = [
    docker_container.postgres,
    docker_container.redis,
  ]

  lifecycle {
    replace_triggered_by = [
      docker_container.postgres.id
    ]
  }
}
