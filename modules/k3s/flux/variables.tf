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

variable "flux_operator_version" {
  type        = string
  description = "Flux Operator Helm chart version"
}

variable "flux_instance" {
  type        = string
  description = "FluxInstance manifest as YAML string"

  validation {
    condition     = can(yamldecode(var.flux_instance))
    error_message = "flux_instance must be valid YAML"
  }
}

variable "discord_webhook_url" {
  type        = string
  description = "Discord webhook URL for Flux notifications"
  sensitive   = true
}

variable "cluster_name" {
  type        = string
  description = "Cluster name included in Flux notification metadata"
}
