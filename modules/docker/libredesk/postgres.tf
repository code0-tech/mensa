data "docker_registry_image" "postgres" {
  name = "postgres:17-alpine"
}

resource "docker_image" "postgres" {
  name          = data.docker_registry_image.postgres.name
  pull_triggers = [data.docker_registry_image.postgres.sha256_digest]
}

resource "docker_volume" "pgdata" {
  name = "${var.docker_name_prefix}libredesk_pgdata"
}

resource "random_password" "db" {
  length  = 32
  special = false
}

locals {
  postgres_env = [
    "POSTGRES_USER=libredesk",
    "POSTGRES_PASSWORD=${random_password.db.result}",
    "POSTGRES_DB=libredesk",
  ]
}

//noinspection HILUnresolvedReference
resource "docker_container" "postgres" {
  image   = docker_image.postgres.image_id
  name    = "${var.docker_name_prefix}libredesk_postgres"
  restart = "always"

  env = local.postgres_env

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -U libredesk -d libredesk"]
    interval = "10s"
    timeout  = "5s"
    retries  = 6
  }

  volumes {
    volume_name    = docker_volume.pgdata.name
    container_path = "/var/lib/postgresql/data"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.libredesk.name
  }

  lifecycle {
    replace_triggered_by = [
      docker_volume.pgdata.id
    ]
  }
}
