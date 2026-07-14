locals {
  override_env_content = <<ENV
HOSTNAME=demo.codezero.build
SSL_ENABLED=false

INITIAL_ROOT_MAIL=root@code0.tech
INITIAL_ROOT_PASSWORD=${random_password.initial_root_password.result}

INITIAL_RUNTIME_TOKEN=${random_password.initial_runtime_token.result}
AQUILA_BACKEND_TOKEN=${random_password.initial_runtime_token.result}

DRACO_REST_PORT=443
DRACO_REST_HOST=demo-rest.codezero.build

TAURUS_AQUILA_TOKEN=${random_password.taurus_aquila_token.result}
DRACO_REST_AQUILA_TOKEN=${random_password.draco_rest_aquila_token.result}
DRACO_CRON_AQUILA_TOKEN=${random_password.draco_cron_aquila_token.result}

COMPOSE_PROFILES=ide,runtime,ide_velorum

IMAGE_REGISTRY=ghcr.io/code0-tech/reticulum/ci-builds
IMAGE_TAG=0.0.0-experimental-2675315513-d32929710bf631cbba87aded1545f0f58c340119
IMAGE_EDITION=ce

SAGITTARIUS_DB_ENCRYPTION_PRIMARY_KEY=${random_password.sagittarius_db_encryption_primary_key.result}
SAGITTARIUS_DB_ENCRYPTION_DETERMINISTIC_KEY=${random_password.sagittarius_db_encryption_deterministic_key.result}
SAGITTARIUS_DB_ENCRYPTION_KEY_DERIVATION_SALT=${random_password.sagittarius_db_encryption_derivation_salt.result}
SAGITTARIUS_RAILS_SECRET_KEY_BASE=${random_password.sagittarius_rails_secret_key_base.result}

VELORUM_MODEL_GPTOSS120B_IDENTIFIER=gpt-oss-120b
VELORUM_MODEL_GPTOSS120B_NAME='GPT OSS 120B'
VELORUM_MODEL_GPTOSS120B_CAPABILITIES=explain,generate
VELORUM_MODEL_GPTOSS120B_PROVIDER=openrouter/openai/gpt-oss-120b
VELORUM_MODEL_GPTOSS120B_AUTH=${sensitive(data.gitlab_project_variable.openrouter_api_key.value)}
VELORUM_MODEL_GPTOSS120B_TOKEN_COST=1

POSTGRES_USER=sagittarius
POSTGRES_PASSWORD=${random_password.postgres_password.result}

PROXY_NETWORK=${var.proxy_network}

AQUILA_ACTION_GLS_IDENTIFIER=gls
AQUILA_ACTION_GLS_TOKEN=${random_password.action_gls_token.result}
AQUILA_ACTION_SHOPIFY_IDENTIFIER=shopify
AQUILA_ACTION_SHOPIFY_TOKEN=${random_password.action_shopify_token.result}
AQUILA_ACTION_SHOPWARE_IDENTIFIER=shopware
AQUILA_ACTION_SHOPWARE_TOKEN=${random_password.action_shopware_token.result}
AQUILA_ACTION_WOOCOMMERCE_IDENTIFIER=woocommerce
AQUILA_ACTION_WOOCOMMERCE_TOKEN=${random_password.action_woocommerce_token.result}

ACTION_IMAGE_REGISTRY=ghcr.io/code0-tech/centaurus/ci-builds
ACTION_IMAGE_TAG=0.0.0-experimental-2671119213-c64c074cd4fbb09109092220fa4beac39f3e4d3d

ENV
}

resource "terraform_data" "env_file" {
  triggers_replace = [
    sha256(local.override_env_content),
    filesha256("${path.module}/.env"),
    filesha256("${path.module}/docker-compose.yml"),
    filesha256("${path.module}/docker-compose.override.yml"),
    filesha256("${path.module}/docker-compose.actions.yml"),
  ]

  provisioner "local-exec" {
    command = "cat <<'ENVEOF' > ${path.module}/override.env\n${local.override_env_content}\nENVEOF"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/override.env"
  }
}

resource "docker_compose" "codezero" {
  project_name = "codezero"
  env_files    = [
    "${path.module}/.env",
    "${path.module}/override.env",
  ]
  config_paths = [
    "${path.module}/docker-compose.yml",
    "${path.module}/docker-compose.override.yml",
    "${path.module}/docker-compose.actions.yml",
  ]

  depends_on = [terraform_data.env_file]

  lifecycle {
    replace_triggered_by = [terraform_data.env_file]
  }
}
