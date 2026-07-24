terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.13.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.0.0"
    }
  }
}
