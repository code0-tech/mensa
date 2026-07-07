resource "random_password" "initial_root_password" {
  length  = 16
  special = false
}

resource "random_password" "initial_runtime_token" {
  length  = 16
  special = false
}

resource "random_password" "taurus_aquila_token" {
  length  = 16
  special = false
}

resource "random_password" "draco_rest_aquila_token" {
  length  = 16
  special = false
}

resource "random_password" "draco_cron_aquila_token" {
  length  = 16
  special = false
}

resource "random_password" "sagittarius_db_encryption_primary_key" {
  length  = 32
  special = false
}

resource "random_password" "sagittarius_db_encryption_deterministic_key" {
  length  = 32
  special = false
}

resource "random_password" "sagittarius_db_encryption_derivation_salt" {
  length  = 32
  special = false
}

resource "random_password" "sagittarius_rails_secret_key_base" {
  length  = 32
  special = false
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}

data "gitlab_project_variable" "openrouter_api_key" {
  project = "code0-tech/secret-manager"
  key     = "MENSA_DEMO_VELORUM_OPENROUTER_KEY"
}

resource "random_password" "action_gls_token" {
  length  = 16
  special = false
}

resource "random_password" "action_shopify_token" {
  length  = 16
  special = false
}
