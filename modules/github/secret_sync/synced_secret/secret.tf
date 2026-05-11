data "gitlab_project_variable" "secret" {
  project = "code0-tech/secret-manager"
  key     = var.gitlab_secrets_manager_key
}

data "github_repositories" "public" {
  query = "org:code0-tech props.secret-sync:${var.github_secret_key} visibility:public"
  include_repo_id = true
}

data "github_repositories" "private" {
  query = "org:code0-tech props.secret-sync:${var.github_secret_key} visibility:private"
}

resource "github_actions_organization_secret" "secret" {
  secret_name = var.github_secret_key
  visibility  = "selected"
  value       = data.gitlab_project_variable.secret.value
}

resource "github_actions_organization_secret_repositories" "public" {
  secret_name             = github_actions_organization_secret.secret.secret_name
  selected_repository_ids = data.github_repositories.public.repo_ids
}

resource "github_actions_secret" "secret" {
  for_each = toset(data.github_repositories.private.names)

  repository = each.value
  secret_name = var.github_secret_key
  value       = data.gitlab_project_variable.secret.value
}
