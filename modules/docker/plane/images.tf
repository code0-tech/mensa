data "docker_registry_image" "plane_frontend" {
  name = "makeplane/plane-frontend:v0.22-dev"
}

resource "docker_image" "plane_frontend" {
  name          = data.docker_registry_image.plane_frontend.name
  pull_triggers = [data.docker_registry_image.plane_frontend.sha256_digest]
}

data "docker_registry_image" "plane_space" {
  name = "makeplane/plane-space:v0.22-dev"
}

resource "docker_image" "plane_space" {
  name          = data.docker_registry_image.plane_space.name
  pull_triggers = [data.docker_registry_image.plane_space.sha256_digest]
}

data "docker_registry_image" "plane_admin" {
  name = "makeplane/plane-admin:v0.22-dev"
}

resource "docker_image" "plane_admin" {
  name          = data.docker_registry_image.plane_admin.name
  pull_triggers = [data.docker_registry_image.plane_admin.sha256_digest]
}

data "docker_registry_image" "plane_backend" {
  name = "makeplane/plane-backend:v0.22-dev"
}

resource "docker_image" "plane_backend" {
  name          = data.docker_registry_image.plane_backend.name
  pull_triggers = [data.docker_registry_image.plane_backend.sha256_digest]
}

data "docker_registry_image" "plane_proxy" {
  name = "makeplane/plane-proxy:v0.22-dev"
}

resource "docker_image" "plane_proxy" {
  name          = data.docker_registry_image.plane_proxy.name
  pull_triggers = [data.docker_registry_image.plane_proxy.sha256_digest]
}

data "docker_registry_image" "postgres" {
  name = "postgres:15.7-alpine"
}

resource "docker_image" "postgres" {
  name          = data.docker_registry_image.postgres.name
  pull_triggers = [data.docker_registry_image.postgres.sha256_digest]
}

data "docker_registry_image" "valkey" {
  name = "valkey/valkey:7.2.5-alpine"
}

resource "docker_image" "valkey" {
  name          = data.docker_registry_image.valkey.name
  pull_triggers = [data.docker_registry_image.valkey.sha256_digest]
}

data "docker_registry_image" "minio" {
  name = "minio/minio:RELEASE.2024-07-10T18-41-49Z"
}

resource "docker_image" "minio" {
  name          = data.docker_registry_image.minio.name
  pull_triggers = [data.docker_registry_image.minio.sha256_digest]
}
