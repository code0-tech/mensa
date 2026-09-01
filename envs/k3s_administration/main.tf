terraform {
  backend "http" {}

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.3.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.3.0"
    }
  }
}

provider "gitlab" {
  token    = var.gitlab_api_token
  base_url = "https://gitlab.com/api/v4/"
}

resource "gitlab_cluster_agent" "this" {
  project = "code0-tech/infrastructure/mensa"
  name    = "k3s-administration"
}

resource "gitlab_cluster_agent_token" "this" {
  project  = gitlab_cluster_agent.this.project
  agent_id = gitlab_cluster_agent.this.agent_id
  name     = "default"
}

data "gitlab_project_variable" "discord_webhook_url" {
  project = "code0-tech/secret-manager"
  key     = "FLUX_DISCORD_WEBHOOK_URL"
}

module "server_node" {
  source = "../../modules/k3s/server_node"

  ssh_host = var.server_administration_ip
  ssh_port = var.server_administration_ssh_port
  ssh_user = "pipeline"

  k3s_version = "v1.36.4+k3s1"
  datastore   = "sqlite"
  tls_san     = [var.server_administration_ip]
}

module "flux" {
  source = "../../modules/k3s/flux"

  ssh_host = var.server_administration_ip
  ssh_port = var.server_administration_ssh_port
  ssh_user = "pipeline"

  flux_operator_version = "0.58.1"
  flux_instance         = file("${path.module}/flux-instance.yaml")
  discord_webhook_url   = data.gitlab_project_variable.discord_webhook_url.value
  cluster_name          = "administration"

  depends_on = [module.server_node]
}

module "gitlab_agent" {
  source = "../../modules/k3s/gitlab_agent"

  ssh_host = var.server_administration_ip
  ssh_port = var.server_administration_ssh_port
  ssh_user = "pipeline"

  agent_version = "2.30.0"
  agent_token   = gitlab_cluster_agent_token.this.token

  depends_on = [module.flux]
}
