resource "random_password" "codezero_initial_root_password" {
  length  = 32
  special = false
}

resource "docker_network" "codezero_staging" {
  name = "codezero_staging"
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

data "gitlab_project_variable" "libredesk_inbox_secret_staging" {
  project = "code0-tech/secret-manager"
  key     = "LIBREDESK_INBOX_SECRET_STAGING"
}

module "codezero" {
  source = "github.com/code0-tech/reticulum//terraform/docker?ref=7f0bdf65950c044316a4b8f117647c48bb8c6211"

  hostname              = "staging.codezero.build"
  initial_root_mail     = "root@code0.tech"
  initial_root_password = random_password.codezero_initial_root_password.result
  image_tag             = "0.0.0-experimental-3030112534-7f0bdf65950c044316a4b8f117647c48bb8c6211"
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
    "SAGITTARIUS_GRAPHQL_URL=http://codezero-nginx/graphql",
    "LIBREDESK_URL=https://support-widget.codezero.build",
    "LIBREDESK_INBOX_ID=79069078-2940-4c21-9bdb-ab81a70af08f",
    "LIBREDESK_SECRET=${sensitive(data.gitlab_project_variable.libredesk_inbox_secret_staging.value)}",
    "LIBREDESK_TOKEN_TTL_MINUTES=720",
  ]
}
