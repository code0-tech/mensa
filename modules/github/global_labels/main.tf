terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.8.0"
    }
  }
}

locals {
  labels = {
    bug = {
      description = "Something isn't working"
      color       = "d73a4a"
    }
    blocked = {
      description = "This is blocked by some other work"
      color       = "9e2204"
    }
    dependencies = {
      description = "This updates dependency files"
      color       = "009966"
    }
    documentation = {
      description = "Improvements or additions to documentation"
      color       = "0075ca"
    }
    duplicate = {
      description = "This issue or pull request already exists"
      color       = "cfd3d7"
    }
    enhancement = {
      description = "New feature or request"
      color       = "a2eeef"
    }
    "good first issue" = {
      description = "Good for newcomers"
      color       = "7057ff"
    }
    "help wanted" = {
      description = "Extra attention is needed"
      color       = "008672"
    }
    invalid = {
      description = "This doesn't seem right"
      color       = "e4e669"
    }
    question = {
      description = "Further information is requested"
      color       = "d876e3"
    }
    tooling = {
      description = "Related to project internal processes or tooling"
      color       = "7f8c8d"
    }
    wontfix = {
      description = "This will not be worked on"
      color       = "ffffff"
    }
  }
}

resource "github_issue_label" "global_labels" {
  for_each = local.labels

  color       = each.value["color"]
  name        = each.key
  description = each.value["description"]
  repository  = var.repository
}
