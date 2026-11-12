data "docker_registry_image" "cygnus" {
  name = "ghcr.io/code0-tech/cygnus:2414"
}

data "gitlab_project_variable" "stripe_public_key" {
  project = "code0-tech/secret-manager"
  key     = "STRIPE_STAGING_PUBLIC_KEY"
}

module "cygnus" {
  source = "../../modules/docker/cygnus"

  web_urls                     = ["staging-cygnus.codezero.build"]
  docker_additional_network_id = docker_network.codezero_staging.name
  docker_name_prefix           = "staging_"
  bind_ip                      = "127.0.0.1"
  http_port                    = 15243
  cygnus_image = {
    name          = data.docker_registry_image.cygnus.name
    sha256_digest = data.docker_registry_image.cygnus.sha256_digest
  }
  additional_envs = [
    "CRATER_GRAPHQL_URL=http://${module.crater.container_hostname}:3000/graphql",
    "PAYLOAD_SKIP_EMAIL_VERIFY=true",
    "STRIPE_PUBLIC_KEY=${data.gitlab_project_variable.stripe_public_key.value}",
    "SCULPTOR_URL=https://staging.codezero.build",
    "SCULPTOR_LOGIN_URL=https://staging.codezero.build/redirect",
  ]
}
