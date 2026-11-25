locals {
  action_version = "0.0.0-experimental-3110890925-74bc6b9fd657508ded2f333c19efac4ceed83cf4"
}

data "docker_registry_image" "codezero_rest_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/rest-action:${local.action_version}"
}

module "codezero_rest_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "rest"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_rest_action.name
    sha256_digest = data.docker_registry_image.codezero_rest_action.sha256_digest
  }

  additional_envs = [
    "VIRTUAL_HOST=rest-staging.codezero.build",
    "VIRTUAL_PORT=8080",
  ]
  docker_networks = [
    module.proxy.docker_proxy_network_name,
    module.codezero.aquila_network.name,
  ]
}

data "docker_registry_image" "codezero_cron_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/cron-action:${local.action_version}"
}

module "codezero_cron_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "cron"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_cron_action.name
    sha256_digest = data.docker_registry_image.codezero_cron_action.sha256_digest
  }

  docker_networks = [
    module.codezero.aquila_network.name,
  ]
}

data "docker_registry_image" "codezero_smtp_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/smtp-action:${local.action_version}"
}

module "codezero_smtp_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "smtp"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_smtp_action.name
    sha256_digest = data.docker_registry_image.codezero_smtp_action.sha256_digest
  }

  docker_networks = [
    module.codezero.aquila_network.name,
  ]
}

data "docker_registry_image" "codezero_discord_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/discord-action:${local.action_version}"
}

module "codezero_discord_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "discord"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_discord_action.name
    sha256_digest = data.docker_registry_image.codezero_discord_action.sha256_digest
  }

  docker_networks = [
    module.codezero.aquila_network.name,
  ]
}

data "docker_registry_image" "codezero_github_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/github-action:${local.action_version}"
}

module "codezero_github_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "github"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_github_action.name
    sha256_digest = data.docker_registry_image.codezero_github_action.sha256_digest
  }

  docker_networks = [
    module.codezero.aquila_network.name,
  ]
}

data "docker_registry_image" "codezero_mcp_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/mcp-action:${local.action_version}"
}

module "codezero_mcp_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "mcp"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_mcp_action.name
    sha256_digest = data.docker_registry_image.codezero_mcp_action.sha256_digest
  }

  docker_networks = [
    module.codezero.aquila_network.name,
  ]
}

data "docker_registry_image" "codezero_ai_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/ai-action:${local.action_version}"
}

module "codezero_ai_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "ai"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_ai_action.name
    sha256_digest = data.docker_registry_image.codezero_ai_action.sha256_digest
  }

  docker_networks = [
    module.codezero.aquila_network.name,
  ]
}

data "docker_registry_image" "codezero_twilio_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/twilio-action:${local.action_version}"
}

module "codezero_twilio_action" {
  source = "../../modules/docker/codezero-action"

  identifier = "twilio"
  aquila_url = "codezero-aquila:8081"
  image = {
    name          = data.docker_registry_image.codezero_twilio_action.name
    sha256_digest = data.docker_registry_image.codezero_twilio_action.sha256_digest
  }

  docker_networks = [
    module.codezero.aquila_network.name,
  ]
}
