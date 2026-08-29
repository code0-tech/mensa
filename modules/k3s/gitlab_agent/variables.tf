variable "ssh_host" {
  type        = string
  description = "IP or hostname of a server node"
  sensitive   = true
}

variable "ssh_port" {
  type        = string
  description = "SSH port"
  sensitive   = true
}

variable "ssh_user" {
  type        = string
  description = "SSH user"
  default     = "pipeline"
}

variable "agent_version" {
  type        = string
  description = "GitLab Agent chart version"
}

variable "agent_token" {
  type        = string
  description = "Registration token for the GitLab Agent"
  sensitive   = true
}

variable "kas_address" {
  type        = string
  description = "GitLab KAS address"
  default     = "wss://kas.gitlab.com"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy the GitLab Agent into"
  default     = "gitlab-agent"
}
