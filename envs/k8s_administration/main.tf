terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.24.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

provider "gitlab" {
  token    = var.gitlab_api_token
  base_url = "https://gitlab.com/api/v4/"
}

data "gitlab_project_variable" "teleport_github_client_id" {
  project = "code0-tech/secret-manager"
  key     = "TELEPORT_GITHUB_CLIENT_ID"
}

data "gitlab_project_variable" "teleport_github_client_secret" {
  project = "code0-tech/secret-manager"
  key     = "TELEPORT_GITHUB_CLIENT_SECRET"
}

module "teleport" {
  source = "../../system/teleport"

  cloudflare_account_id  = var.cloudflare_account_id
  server_ip              = var.server_administration_ip
  hostname               = "tp.code0.tech"
  chart_version          = "18.11.0"
  config_oci_url         = "oci://registry.gitlab.com/code0-tech/infrastructure/mensa/teleport-config"
  config_oci_tag         = var.teleport_config_tag
  teleport_cluster_label = "administration"

  config_substitution_vars = {
    GITHUB_CLIENT_ID      = data.gitlab_project_variable.teleport_github_client_id.value
    GITHUB_CLIENT_SECRET  = data.gitlab_project_variable.teleport_github_client_secret.value
  }
}
