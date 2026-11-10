terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.28.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.4.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.5.0"
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

  cloudflare_account_id = var.cloudflare_account_id
  server_ip             = var.server_administration_ip
  hostname              = "tp.code0.tech"
  # renovate: datasource=helm depName=teleport-cluster registryUrl=https://charts.releases.teleport.dev
  chart_version          = "18.11.8"
  config_oci_url         = "oci://registry.gitlab.com/code0-tech/infrastructure/mensa/teleport-config"
  config_oci_tag         = var.teleport_config_tag
  teleport_cluster_label = "administration"

  config_substitution_vars = {
    GITHUB_CLIENT_ID     = data.gitlab_project_variable.teleport_github_client_id.value
    GITHUB_CLIENT_SECRET = data.gitlab_project_variable.teleport_github_client_secret.value
  }
}

module "signoz" {
  source = "../../modules/k8s/signoz"

  # renovate: datasource=helm depName=signoz registryUrl=https://charts.signoz.io
  chart_version = "0.149.0"
  cluster_name  = "administration"
}

data "gitlab_project_variable" "gitlab_runner_token_infra_release_tools" {
  project = "code0-tech/secret-manager"
  key     = "GITLAB_RUNNER_TOKEN_INFRA_RELEASE_TOOLS"
}

module "gitlab_runner" {
  source = "../../modules/k8s/gitlab-runner"

  # renovate: datasource=docker depName=gitlab-runner registryUrl=https://registry.gitlab.com/charts/charts.gitlab.io/release
  chart_version = "0.94.3"
  runner_token  = data.gitlab_project_variable.gitlab_runner_token_infra_release_tools.value
  concurrent    = 1
}
