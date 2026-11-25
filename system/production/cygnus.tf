data "docker_registry_image" "cygnus" {
  name = "ghcr.io/code0-tech/cygnus:2526"
}

data "gitlab_project_variable" "stripe_public_key" {
  project = "code0-tech/secret-manager"
  key     = "STRIPE_PRODUCTION_PUBLIC_KEY"
}

module "cygnus" {
  source = "../../modules/docker/cygnus"

  web_urls                      = ["codezero.build"]
  docker_additional_network_ids = [docker_network.codezero_production.name, module.proxy.docker_proxy_network_name]
  docker_name_prefix            = "production_"
  cygnus_image = {
    name          = data.docker_registry_image.cygnus.name
    sha256_digest = data.docker_registry_image.cygnus.sha256_digest
  }
  additional_envs = [
    "CRATER_GRAPHQL_URL=http://${module.crater.container_hostname}:3000/graphql",
    "PAYLOAD_SKIP_EMAIL_VERIFY=true",
    "STRIPE_PUBLIC_KEY=${data.gitlab_project_variable.stripe_public_key.value}",
    "SCULPTOR_URL=https://cloud.codezero.build",
    "SCULPTOR_LOGIN_URL=https://cloud.codezero.build/redirect",
  ]
}
