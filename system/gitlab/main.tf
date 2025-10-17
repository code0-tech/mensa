terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "18.5.0"
    }
  }
}

data "gitlab_project_variable" "runner_support_token" {
  project = "code0-tech/secret-manager"
  key     = "GITHUB_RUNNER_SUPPORT_TOKEN"
}

resource "gitlab_project_hook" "runner_support" {
  for_each = {
    "code0-tech/development/sagittarius": "runner-support",
    "code0-tech/development/reticulum": "runner-support",
    "code0-tech/infrastructure/pyxis": "runner-support-infra",
  }

  project = each.key
  url     = "https://api.github.com/repos/code0-tech/monoceros/actions/workflows/${each.value}.yml/dispatches"

  push_events = false
  pipeline_events = true

  custom_webhook_template = jsonencode(
    {
      "ref": "main",
      "inputs": {
        "project": "{{project.id}}"
      }
    }
  )

  custom_headers = [
    {
      key = "Authorization"
      value = "Bearer ${data.gitlab_project_variable.runner_support_token.value}"
    }
  ]
}
