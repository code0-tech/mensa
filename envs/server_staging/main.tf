terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.25.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "19.4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
    stripe = {
      source = "stripe/stripe"
      version = "0.3.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "gitlab" {
  token = var.gitlab_api_token
  base_url = "https://gitlab.com/api/v4/"
}

provider "docker" {
  host = "ssh://pipeline@${var.server_staging_ip}:${var.server_staging_ssh_port}"

  cert_path = ""

  registry_auth {
    address = "registry.gitlab.com"
    username = "gitlab-ci-token"
    password = var.gitlab_api_token
  }
}

provider "stripe" {
  api_key = var.stripe_staging_api_key
}

module "staging" {
  source = "../../system/staging"

  cloudflare_account_id = var.cloudflare_account_id
  server_staging_ip     = var.server_staging_ip
}
