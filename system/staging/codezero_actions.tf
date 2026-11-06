data "docker_registry_image" "codezero_rest_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/rest-action:0.0.0-experimental-3028768426-71ac23091efd1ca7268de29f7507f99bea193420"
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
  name = "ghcr.io/code0-tech/centaurus/ci-builds/cron-action:0.0.0-experimental-3028768426-71ac23091efd1ca7268de29f7507f99bea193420"
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
