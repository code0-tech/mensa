terraform {
  backend "http" {}

  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "18.8.2"
    }
    github = {
      source  = "integrations/github"
      version = "6.11.1"
    }
  }
}

provider "gitlab" {
  token = var.gitlab_api_token
  base_url = "https://gitlab.com/api/v4/"
}

provider "github" {
  owner = "code0-tech"
  app_auth {
    id = "832219"
    installation_id = "47451228"
    pem_file = var.github_app_key
  }
}

module "github" {
  source = "../../system/github"
}
