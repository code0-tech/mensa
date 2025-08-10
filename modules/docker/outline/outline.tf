data "docker_registry_image" "outline" {
  name = "outlinewiki/outline:0.86.1"
}

resource "docker_image" "outline" {
  name          = data.docker_registry_image.outline.name
  pull_triggers = [data.docker_registry_image.outline.sha256_digest]
}

resource "docker_volume" "outlinedata" {
  name = "outline_outlinedata"
}

resource "random_bytes" "secret_key" {
  length = 32
}

resource "random_bytes" "utils_key" {
  length = 32
}

data "gitlab_project_variable" "discord_client_id" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_DISCORD_CLIENT_ID"
}

data "gitlab_project_variable" "discord_client_secret" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_DISCORD_CLIENT_SECRET"
}

data "gitlab_project_variable" "smtp_host" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_SMTP_HOST"
}

data "gitlab_project_variable" "smtp_username" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_SMTP_USERNAME"
}

data "gitlab_project_variable" "smtp_password" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_SMTP_PASSWORD"
}

data "gitlab_project_variable" "smtp_from_email" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_SMTP_FROM_EMAIL"
}

data "gitlab_project_variable" "github_app_id" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_GITHUB_APP_ID"
}

data "gitlab_project_variable" "github_app_private_key" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_GITHUB_APP_PRIVATE_KEY"
}

data "gitlab_project_variable" "github_client_id" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_GITHUB_CLIENT_ID"
}

data "gitlab_project_variable" "github_client_secret" {
  project = "code0-tech/secret-manager"
  key     = "OUTLINE_GITHUB_CLIENT_SECRET"
}

locals {
  //noinspection HILUnresolvedReference
  outline_env = [
    "NODE_ENV=production",
    "SECRET_KEY=${random_bytes.secret_key.hex}",
    "UTILS_SECRET=${random_bytes.utils_key.hex}",
    "DATABASE_URL=postgres://outline:${random_password.db.result}@${docker_container.postgres.hostname}:5432/outline",
    "PGSSLMODE=disable",
    "REDIS_URL=redis://${docker_container.redis.hostname}:6379",
    "URL=https://${var.web_url}",
    "PORT=3000",
    "FILE_STORAGE=local",
    "FILE_STORAGE_LOCAL_ROOT_DIR=/var/lib/outline/data",
    "FILE_STORAGE_UPLOAD_MAX_SIZE=262144000",
    "DISCORD_CLIENT_ID=${data.gitlab_project_variable.discord_client_id.value}",
    "DISCORD_CLIENT_SECRET=${data.gitlab_project_variable.discord_client_secret.value}",
    "DISCORD_SERVER_ID=1173625923724124200",
    "DISCORD_SERVER_ROLES=1173713224387014696",
    "FORCE_HTTPS=false", # terminated at proxy
    "SMTP_HOST=${data.gitlab_project_variable.smtp_host.value}",
    "SMTP_PORT=587",
    "SMTP_USERNAME=${data.gitlab_project_variable.smtp_username.value}",
    "SMTP_PASSWORD=${data.gitlab_project_variable.smtp_password.value}",
    "SMTP_FROM_EMAIL=${data.gitlab_project_variable.smtp_from_email.value}",
    "GITHUB_CLIENT_ID=${data.gitlab_project_variable.github_client_id.value}",
    "GITHUB_CLIENT_SECRET=${data.gitlab_project_variable.github_client_secret.value}",
    "GITHUB_APP_NAME=code0-outline",
    "GITHUB_APP_ID=${data.gitlab_project_variable.github_app_id.value}",
    "GITHUB_APP_PRIVATE_KEY=${data.gitlab_project_variable.github_app_private_key.value}",

    # Proxy
    "VIRTUAL_HOST=${var.web_url}",
  ]
}

//noinspection HILUnresolvedReference
resource "docker_container" "outline" {
  image   = docker_image.outline.image_id
  name    = "outline_outline"
  restart = "always"

  env = local.outline_env

  volumes {
    volume_name    = docker_volume.outlinedata.name
    container_path = "/var/lib/outline/data"
  }

  network_mode = "bridge"

  networks_advanced {
    name = docker_network.outline.name
  }

  networks_advanced {
    name = var.docker_proxy_network_id
  }

  lifecycle {
    replace_triggered_by = [
      docker_container.postgres.id,
      docker_container.redis.id,
    ]
  }
}
