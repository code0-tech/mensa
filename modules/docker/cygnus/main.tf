terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.5.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.3.0"
    }
  }
}
