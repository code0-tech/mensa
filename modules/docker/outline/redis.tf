data "docker_registry_image" "redis" {
  name = "redis:7.4.7"
}

resource "docker_image" "redis" {
  name          = data.docker_registry_image.redis.name
  pull_triggers = [data.docker_registry_image.redis.sha256_digest]
}

resource "docker_volume" "redisdata" {
  name = "outline_redisdata"
}

//noinspection HILUnresolvedReference
resource "docker_container" "redis" {
  image   = docker_image.redis.image_id
  name    = "outline_redis"
  restart = "always"

  volumes {
    volume_name    = docker_volume.redisdata.name
    container_path = "/data"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.outline.name
  }
}
