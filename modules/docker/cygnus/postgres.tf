data "docker_registry_image" "postgres" {
  name = "postgres:18-alpine"
}

resource "docker_image" "postgres" {
  name          = data.docker_registry_image.postgres.name
  pull_triggers = [data.docker_registry_image.postgres.sha256_digest]
}

resource "docker_volume" "pgdata" {
  name = "cygnus_pgdata"
}

resource "random_password" "db" {
  length  = 32
  special = false
}

locals {
  postgres_env = [
    "POSTGRES_USER=cygnus",
    "POSTGRES_PASSWORD=${random_password.db.result}",
    "POSTGRES_DB=payload",
    "POSTGRES_PORT=5432",
  ]
}

//noinspection HILUnresolvedReference
resource "docker_container" "postgres" {
  image   = docker_image.postgres.image_id
  name    = "cygnus_postgres"
  restart = "always"

  env = local.postgres_env

  volumes {
    volume_name    = docker_volume.pgdata.name
    container_path = "/var/lib/postgresql"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.cygnus.name
  }

  lifecycle {
    replace_triggered_by = [
      docker_volume.pgdata.id
    ]
  }
}
