terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.8.0"
    }
  }
}

locals {
  release_tools_app_id = 857194
}

data "github_team" "delivery" {
  slug = "delivery"
  summary_only = true
}

data "github_repositories" "release_tools_versioning" {
  query = "org:code0-tech props.versioning:release-tools"
}

resource "github_team_repository" "delivery_team_permission" {
  for_each = toset(data.github_repositories.release_tools_versioning.names)

  team_id    = data.github_team.delivery.id
  repository = each.value
  permission = "push"
}

resource "github_repository_ruleset" "stable_branch_rule" {
  for_each = toset(data.github_repositories.release_tools_versioning.names)
  name = "Stable branch (release-tools managed)"
  repository = each.value
  target = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/heads/*-stable"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = data.github_team.delivery.id
    actor_type  = "Team"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = local.release_tools_app_id
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    creation = true
    update = true
    deletion = true
  }
}

resource "github_repository_ruleset" "tag_rule" {
  for_each = toset(data.github_repositories.release_tools_versioning.names)
  name = "Tags (release-tools managed)"
  repository = each.value
  target = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  bypass_actors {
    actor_id    = data.github_team.delivery.id
    actor_type  = "Team"
    bypass_mode = "always"
  }

  bypass_actors {
    actor_id    = local.release_tools_app_id
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  rules {
    creation = true
    update = true
    deletion = true
  }
}
