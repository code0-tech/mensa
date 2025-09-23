terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.6.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "18.4.1"
    }
  }
}

data "github_repositories" "repositories" {
  query = "org:code0-tech"
}

data "github_repositories" "public_repositories" {
  query = "org:code0-tech visibility:public"
}

data "github_repositories" "private_repositories" {
  query = "org:code0-tech visibility:private"
}

module "global_labels" {
  source = "../../modules/github/global_labels"

  for_each = toset(data.github_repositories.repositories.names)
  repository = each.value
}

module "release_tools_configs" {
  source = "../../modules/github/release_tools_configs"
}

data "gitlab_project_variable" "github_public_discord_webhook_url" {
  project = "code0-tech/secret-manager"
  key     = "GITHUB_PUBLIC_DISCORD_WEBHOOK_URL"
}

data "gitlab_project_variable" "github_private_discord_webhook_url" {
  project = "code0-tech/secret-manager"
  key     = "GITHUB_PRIVATE_DISCORD_WEBHOOK_URL"
}

resource "github_repository_webhook" "public_discord_webhook" {
  for_each = toset(data.github_repositories.public_repositories.names)

  repository = each.value

  events = [
    "discussion",
    "fork",
    "issues",
    "pull_request",
    "pull_request_review",
    "push",
    "release",
    "star",
    "watch"
  ]

  configuration {
    //noinspection HILUnresolvedReference
    url = data.gitlab_project_variable.github_public_discord_webhook_url.value
    content_type = "json"
  }
}

resource "github_repository_webhook" "private_discord_webhook" {
  for_each = toset(data.github_repositories.private_repositories.names)

  repository = each.value

  events = [
    "discussion",
    "fork",
    "issues",
    "pull_request",
    "pull_request_review",
    "push",
    "release",
    "star",
    "watch"
  ]

  configuration {
    //noinspection HILUnresolvedReference
    url = data.gitlab_project_variable.github_private_discord_webhook_url.value
    content_type = "json"
  }
}
