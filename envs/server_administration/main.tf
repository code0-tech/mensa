terraform {
  backend "http" {}

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.5.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "18.0.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.4.0"
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
  host = "ssh://pipeline@${var.server_administration_ip}:${var.server_administration_ssh_port}"

  cert_path = ""
}

module "administration" {
  source = "../../system/administration"

  cloudflare_account_id    = var.cloudflare_account_id
  server_administration_ip = var.server_administration_ip
}
