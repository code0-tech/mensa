terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.8.2"
    }
  }
}

data "docker_registry_image" "pyxis" {
  name = "ghcr.io/code0-tech/pyxis:41"
}

resource "docker_image" "pyxis" {
  name          = data.docker_registry_image.pyxis.name
  pull_triggers = [data.docker_registry_image.pyxis.sha256_digest]
}

data "gitlab_project_variable" "discord_bot_token" {
  project = "code0-tech/infrastructure/pyxis"
  key     = "PYXIS_DC_RELEASE_TOOLS_TOKEN"
}

data "gitlab_project_variable" "github_release_tools_private_key" {
  project = "code0-tech/infrastructure/pyxis"
  key     = "PYXIS_GH_RELEASE_TOOLS_PRIVATE_KEY"
}

data "gitlab_project_variable" "github_release_tools_approver_private_key" {
  project = "code0-tech/infrastructure/pyxis"
  key     = "PYXIS_GH_RELEASE_TOOLS_APPROVER_PRIVATE_KEY"
}

data "gitlab_project_variable" "github_reticulum_publish_token" {
  project = "code0-tech/infrastructure/pyxis"
  key     = "PYXIS_GH_RETICULUM_PUBLISH_TOKEN"
}

data "gitlab_project_variable" "gitlab_release_tools_private_token" {
  project = "code0-tech/infrastructure/pyxis"
  key     = "PYXIS_GL_RELEASE_TOOLS_PRIVATE_TOKEN"
}

resource "docker_container" "pyxis" {
  //noinspection HILUnresolvedReference
  image   = docker_image.pyxis.image_id
  name    = "pyxis"
  restart = "always"

  command = ["bin/discord"]

  upload {
    file    = "/pyxis/secrets/github_release_tools_private_key"
    content = sensitive(data.gitlab_project_variable.github_release_tools_private_key.value)
  }

  upload {
    file    = "/pyxis/secrets/gitlab_release_tools_private_token"
    content = sensitive(data.gitlab_project_variable.gitlab_release_tools_private_token.value)
  }

  upload {
    file    = "/pyxis/secrets/gitlab_release_tools_approver_private_key"
    content = sensitive(data.gitlab_project_variable.github_release_tools_approver_private_key.value)
  }

  upload {
    file    = "/pyxis/secrets/github_reticulum_publish_token"
    content = sensitive(data.gitlab_project_variable.github_reticulum_publish_token.value)
  }

  upload {
    file    = "/pyxis/secrets/discord_bot_token"
    content = sensitive(data.gitlab_project_variable.discord_bot_token.value)
  }

  env = [
    "PYXIS_GH_RELEASE_TOOLS_PRIVATE_KEY=/pyxis/secrets/github_release_tools_private_key",
    "PYXIS_GH_RELEASE_TOOLS_APPROVER_PRIVATE_KEY=/pyxis/secrets/github_release_tools_approver_private_key",
    "PYXIS_GH_RETICULUM_PUBLISH_TOKEN=/pyxis/secrets/github_reticulum_publish_token",
    "PYXIS_GL_RELEASE_TOOLS_PRIVATE_TOKEN=/pyxis/secrets/gitlab_release_tools_private_token",
    "PYXIS_DC_RELEASE_TOOLS_TOKEN=/pyxis/secrets/discord_bot_token",
    "DRY_RUN=false"
  ]
}
