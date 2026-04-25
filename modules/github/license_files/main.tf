terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.12.0"
    }
  }
}

locals {
  license_mappings = {
    "aquila" = "ee"
    "code0-definition" = "mit"
    "code0-flow" = "mit-with-ai-restriction"
    "code0-identities" = "mit-with-ai-restriction"
    "code0-license" = "mit-with-ai-restriction"
    "code0-zero_track" = "mit-with-ai-restriction"
    "cygnus" = "mit"
    "draco" = "ee"
    "hercules" = "mit"
    "lacerta" = "mit"
    "pictor" = "mit"
    "reticulum" = "ee"
    "sagittarius" = "ee-sagittarius"
    "sculptor" = "ee-sculptor"
    "taurus" = "ee"
    "telescopium" = "mit"
    "triangulum" = "mit-with-ai-restriction"
    "tucana" = "mit-with-ai-restriction"
    "codezero" = "ee"
  }
}

data "github_repository" "repository" {
  for_each = local.license_mappings

  name = each.key
}

resource "github_repository_file" "license" {
  for_each            = local.license_mappings
  repository          = each.key
  branch              = data.github_repository.repository[each.key].default_branch
  file                = "LICENSE"
  content             = file("${path.module}/licenses/${each.value}.txt")
  commit_message      = "Update LICENSE file"
  overwrite_on_create = true
}
