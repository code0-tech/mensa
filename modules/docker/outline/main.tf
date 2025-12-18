terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.7.0"
    }
  }
}
