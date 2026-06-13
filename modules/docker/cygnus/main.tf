terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.4.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.11.0"
    }
  }
}
