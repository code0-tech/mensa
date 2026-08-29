variable "ssh_host" {
  type        = string
  description = "IP or hostname of the server"
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

variable "k3s_version" {
  type        = string
  description = "k3s version to install (e.g. v1.36.4+k3s1)"
}

variable "datastore" {
  type        = string
  description = "Datastore mode: 'etcd' (--cluster-init) or 'sqlite'"
  default     = "etcd"

  validation {
    condition     = contains(["etcd", "sqlite"], var.datastore)
    error_message = "datastore must be 'etcd' or 'sqlite'"
  }
}

variable "tls_san" {
  type        = list(string)
  description = "Additional TLS SANs for the k3s API server certificate"
  default     = []
}

variable "flannel_backend" {
  type        = string
  description = "Flannel backend for k3s"
  default     = "wireguard-native"
}
