data "docker_registry_image" "tbot" {
  name = "public.ecr.aws/gravitational/tbot-distroless:18.11.8"
}

data "docker_registry_image" "otel_collector" {
  name = "otel/opentelemetry-collector-contrib:0.165.0"
}

data "gitlab_project_variable" "teleport_signoz_join_token" {
  project = "code0-tech/secret-manager"
  key     = "TELEPORT_STAGING_OTEL_JOIN_TOKEN"
}

locals {
  otel_collector_alias = "opentelemetry-collector"
}

module "otel_agent" {
  source = "../../modules/docker/otel-agent"

  docker_name_prefix = "staging_"
  environment        = "staging"

  docker_additional_network_ids = [module.codezero.default_network.id]

  tbot_image = {
    name          = data.docker_registry_image.tbot.name
    sha256_digest = data.docker_registry_image.tbot.sha256_digest
  }

  otel_collector_image = {
    name          = data.docker_registry_image.otel_collector.name
    sha256_digest = data.docker_registry_image.otel_collector.sha256_digest
  }

  otel_collector_network_aliases = [local.otel_collector_alias]

  teleport_proxy_address = "tp.code0.tech:443"
  teleport_join_token    = data.gitlab_project_variable.teleport_signoz_join_token.value
  signoz_app_name        = "signoz-otlp"
}
