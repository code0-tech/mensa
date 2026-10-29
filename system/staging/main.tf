terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.28.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.5.0"
    }
    stripe = {
      source  = "stripe/stripe"
      version = "0.3.0"
    }
  }
}

data "cloudflare_zones" "code0_tech_domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "code0.tech"
}

data "cloudflare_zones" "codezero_build_domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "codezero.build"
}

resource "cloudflare_dns_record" "server_ip" {
  name    = "server_staging.code0.tech"
  type    = "A"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = var.server_staging_ip
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "server_cname_code0_tech" {
  for_each = toset([
    "signoz.code0.tech",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "server_cname_codezero_build" {
  for_each = toset([
    "crater-staging.codezero.build",
    "rest-staging.codezero.build",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.codezero_build_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}

module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "signoz.code0.tech",
    "crater-staging.codezero.build",
    "rest-staging.codezero.build",
  ]
}

resource "random_password" "codezero_initial_root_password" {
  length  = 32
  special = false
}

resource "random_password" "crater_jwt_secret" {
  length  = 32
  special = false
}

resource "docker_network" "codezero_staging" {
  name = "codezero_staging"
}

data "docker_registry_image" "codezero_rest_action" {
  name = "ghcr.io/code0-tech/centaurus/ci-builds/rest-action:0.0.0-experimental-2857072085-c3191ef79a875c3330e67f2bb21f9691671cba65"
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
  name = "ghcr.io/code0-tech/centaurus/ci-builds/cron-action:0.0.0-experimental-2857072085-c3191ef79a875c3330e67f2bb21f9691671cba65"
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

data "gitlab_project_variable" "staging_smtp_host" {
  project = "code0-tech/secret-manager"
  key     = "STAGING_SMTP_HOST"
}

data "gitlab_project_variable" "staging_smtp_user" {
  project = "code0-tech/secret-manager"
  key     = "STAGING_SMTP_USERNAME"
}

data "gitlab_project_variable" "staging_smtp_password" {
  project = "code0-tech/secret-manager"
  key     = "STAGING_SMTP_PASSWORD"
}

module "codezero" {
  source = "github.com/code0-tech/reticulum//terraform/docker?ref=11ff43eb871a23ec3ddeed0b207dffe9f414384e"

  hostname              = "staging.codezero.build"
  initial_root_mail     = "root@code0.tech"
  initial_root_password = random_password.codezero_initial_root_password.result
  image_tag             = "0.0.0-experimental-3001810673-fd8f2d35c0468edef6108713f85324b75a3f96af"
  image_edition         = "cloud"
  image_registry        = "ghcr.io/code0-tech/reticulum/ci-builds"

  http_port                = 15242
  https_port               = null
  nginx_bind_ip            = "127.0.0.1"
  nginx_additional_network = docker_network.codezero_staging.name

  aquila_actions = {
    rest = {
      identifier = "rest"
      token      = module.codezero_rest_action.action_token
    }
    cron = {
      identifier = "cron"
      token      = module.codezero_cron_action.action_token
    }
  }

  additional_sagittarius_config = yamlencode({
    rails = {
      web = {
        external = {
          host     = "staging.codezero.build"
          port     = 443
          protocol = "https"
        }
      }
      mailer = {
        from = "CodeZero <${data.gitlab_project_variable.staging_smtp_user.value}>"
        smtp_settings = {
          address         = data.gitlab_project_variable.staging_smtp_host.value
          domain          = split("@", data.gitlab_project_variable.staging_smtp_user.value)[1]
          user_name       = data.gitlab_project_variable.staging_smtp_user.value
          password        = data.gitlab_project_variable.staging_smtp_password.value
          enable_starttls = true
        }
      }
    }
    crater = {
      jwt_secret = random_password.crater_jwt_secret.result
    }
  })

  sculptor_env = [
    "SUBSCRIPTION_URL=https://staging-cygnus.codezero.build/licenses",
    "CHECKOUT_URL=https://staging-cygnus.codezero.build/subscription",
  ]
}

module "signoz" {
  source = "../../modules/docker/signoz"

  proxy_network = module.proxy.docker_proxy_network_name
  hostname      = "signoz.code0.tech"
}

module "stripe_config" {
  source = "git::ssh://git@github.com/code0-tech/mensa-private//modules/stripe/config?ref=77cc96eae8f300a1f9c861a272cf07e599b507ff"

  webhook_url = "https://crater-staging.codezero.build/webhooks/stripe"
}

resource "gitlab_project_variable" "stripe_webhook_secret" {
  project = "code0-tech/secret-manager"
  key     = "STRIPE_STAGING_WEBHOOK_SECRET"
  value   = module.stripe_config.webhook_secret

  lifecycle {
    ignore_changes = [value]
  }
}

data "gitlab_project_variable" "stripe_webhook_secret" {
  project = gitlab_project_variable.stripe_webhook_secret.project
  key     = gitlab_project_variable.stripe_webhook_secret.key
}

data "docker_registry_image" "crater" {
  name = "registry.gitlab.com/code0-tech/development/crater:2996180181"
}

data "gitlab_project_secure_file" "license_encryption_key" {
  project = "code0-tech/secret-manager"
  name    = "license_encryption_key_production.key"
}

module "crater" {
  source = "git::ssh://git@github.com/code0-tech/mensa-private//modules/docker/crater?ref=77cc96eae8f300a1f9c861a272cf07e599b507ff"

  docker_name_prefix            = "staging-"
  docker_additional_network_ids = [docker_network.codezero_staging.name, module.proxy.docker_proxy_network_name]
  virtual_host                  = "crater-staging.codezero.build"
  crater_image = {
    name          = data.docker_registry_image.crater.name
    sha256_digest = data.docker_registry_image.crater.sha256_digest
  }
  stripe = {
    api_key        = var.stripe_staging_api_key
    webhook_secret = data.gitlab_project_variable.stripe_webhook_secret.value
  }
  additional_crater_config = yamlencode({
    rails = {
      web = {
        force_ssl = false
        external = {
          host     = "staging-cygnus.codezero.build"
          port     = 443
          protocol = "https"
        }
      }
      mailer = {
        from = "CodeZero <${data.gitlab_project_variable.staging_smtp_user.value}>"
        smtp_settings = {
          address         = data.gitlab_project_variable.staging_smtp_host.value
          domain          = split("@", data.gitlab_project_variable.staging_smtp_user.value)[1]
          user_name       = data.gitlab_project_variable.staging_smtp_user.value
          password        = data.gitlab_project_variable.staging_smtp_password.value
          enable_starttls = true
        }
      }
    }
    sagittarius = {
      host       = "http://${module.codezero.nginx_container_hostname}"
      jwt_secret = random_password.crater_jwt_secret.result
    }
    checkout = {
      allowed_return_origins = [
        "https://staging-cygnus.codezero.build"
      ]
      prices = module.stripe_config.price_ids
    }
  })
  license_encryption_key = data.gitlab_project_secure_file.license_encryption_key.content
}

data "docker_registry_image" "cygnus" {
  name = "ghcr.io/code0-tech/cygnus:2336-crater-test"
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
