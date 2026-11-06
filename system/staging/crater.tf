resource "random_password" "crater_jwt_secret" {
  length  = 32
  special = false
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
  name = "registry.gitlab.com/code0-tech/development/crater:3037008692"
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
