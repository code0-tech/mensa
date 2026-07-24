terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.12.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.1.0"
    }
  }
}
