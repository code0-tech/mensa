variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "gitlab_api_token" {
  type      = string
  sensitive = true
}

variable "server_administration_ip" {
  type      = string
  sensitive = true
}

variable "kubeconfig_path" {
  type        = string
  description = "Kubernetes config to use"
  default     = "~/.kube/config"
}

variable "kubeconfig_context" {
  type        = string
  description = "Kubernetes context to use"
}

variable "teleport_config_tag" {
  type        = string
  description = "OCI artifact tag for Teleport config manifests"
}
