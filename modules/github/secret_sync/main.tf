module "gl_api_token" {
  source = "./synced_secret"

  gitlab_secrets_manager_key = "GITHUB_GL_API_TOKEN"
  github_secret_key = "GL_API_TOKEN"
}

module "gl_runner_token" {
  source = "./synced_secret"

  gitlab_secrets_manager_key = "GITHUB_GL_RUNNER_TOKEN"
  github_secret_key = "GL_RUNNER_TOKEN"
}
