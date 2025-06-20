terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.4.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.1.1"
    }
  }
}
