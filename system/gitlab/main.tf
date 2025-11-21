terraform {
  required_providers {
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "18.6.0"
    }
  }
}

module "runner_support_main" {
  source = "../../modules/gitlab/runner_support_webhook"

  for_each = toset([
    "code0-tech/development/sagittarius",
    "code0-tech/development/reticulum",
  ])

  project = each.value
  runner_type = "runner-support"
}

module "runner_support_infra" {
  source = "../../modules/gitlab/runner_support_webhook"

  for_each = toset([
    "code0-tech/infrastructure/pyxis"
  ])

  project = each.value
  runner_type = "runner-support-infra"
}

module "runner_support_arm" {
  source = "../../modules/gitlab/runner_support_webhook"

  for_each = toset([
    "code0-tech/development/reticulum"
  ])

  project = each.value
  runner_type = "runner-support-arm"
}
