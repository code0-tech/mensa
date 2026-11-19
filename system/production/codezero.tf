resource "random_password" "codezero_initial_root_password" {
  length  = 32
  special = false
}

resource "docker_network" "codezero_production" {
  name = "codezero_production"
}

data "gitlab_project_variable" "production_smtp_host" {
  project = "code0-tech/secret-manager"
  key     = "PRODUCTION_SMTP_HOST"
}

data "gitlab_project_variable" "production_smtp_user" {
  project = "code0-tech/secret-manager"
  key     = "PRODUCTION_SMTP_USERNAME"
}

data "gitlab_project_variable" "production_smtp_password" {
  project = "code0-tech/secret-manager"
  key     = "PRODUCTION_SMTP_PASSWORD"
}

data "gitlab_project_variable" "libredesk_inbox_secret_production" {
  project = "code0-tech/secret-manager"
  key     = "LIBREDESK_INBOX_SECRET_PRODUCTION"
}

module "codezero" {
  source = "github.com/code0-tech/reticulum//terraform/docker?ref=2cb2138cfc3b7d6033dde356c343de094df7616f"

  hostname              = "cloud.codezero.build"
  initial_root_mail     = "root@code0.tech"
  initial_root_password = random_password.codezero_initial_root_password.result
  image_tag             = "0.0.0-experimental-3055782041-ab28d4bb65d27ca3c857e9f6395e4f701d832aa9"
  image_edition         = "cloud"
  image_registry        = "ghcr.io/code0-tech/reticulum/ci-builds"

  nginx_additional_networks = [docker_network.codezero_production.name, module.proxy.docker_proxy_network_name]
  nginx_env = [
    "VIRTUAL_HOST=cloud.codezero.build"
  ]
  http_port  = null
  https_port = null

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

  opentelemetry = {
    enabled               = true
    grpc_host             = "http://${local.otel_collector_alias}:4317"
    logs_http_endpoint    = "http://${local.otel_collector_alias}:4318/v1/logs"
    metrics_http_endpoint = "http://${local.otel_collector_alias}:4318/v1/metrics"
    traces_http_endpoint  = "http://${local.otel_collector_alias}:4318/v1/traces"
  }

  additional_sagittarius_config = yamlencode({
    rails = {
      web = {
        external = {
          host     = "cloud.codezero.build"
          port     = 443
          protocol = "https"
        }
      }
      mailer = {
        from = "CodeZero <${data.gitlab_project_variable.production_smtp_user.value}>"
        smtp_settings = {
          address         = data.gitlab_project_variable.production_smtp_host.value
          domain          = split("@", data.gitlab_project_variable.production_smtp_user.value)[1]
          user_name       = data.gitlab_project_variable.production_smtp_user.value
          password        = sensitive(data.gitlab_project_variable.production_smtp_password.value)
          enable_starttls = true
        }
      }
    }
    crater = {
      jwt_secret = random_password.crater_jwt_secret.result
    }
  })

  sculptor_env = [
    "SUBSCRIPTION_URL=https://codezero.build/licenses",
    "CHECKOUT_URL=https://codezero.build/subscription",
    "SAGITTARIUS_GRAPHQL_URL=http://codezero-nginx/graphql",
    "LIBREDESK_URL=https://support-widget.codezero.build",
    "LIBREDESK_INBOX_ID=5addb522-8f2c-495b-aade-241f884759eb",
    "LIBREDESK_SECRET=${sensitive(data.gitlab_project_variable.libredesk_inbox_secret_production.value)}",
    "LIBREDESK_TOKEN_TTL_MINUTES=720",
  ]
}
