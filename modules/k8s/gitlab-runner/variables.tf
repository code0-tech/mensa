variable "chart_version" {
  type        = string
  description = "gitlab-runner Helm chart version"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy gitlab-runner into"
  default     = "gitlab-runner"
}

variable "runner_token" {
  type        = string
  description = "Authentication token for the gitlab-runner"
  sensitive   = true
}

variable "concurrent" {
  type        = number
  description = "Number of jobs this runner should execute concurrently"
  default     = 10
}
