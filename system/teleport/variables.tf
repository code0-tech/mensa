variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "server_ip" {
  type      = string
  sensitive = true
}

variable "hostname" {
  type        = string
  description = "FQDN for the Teleport cluster (e.g. tp.code0.tech)"
}

variable "chart_version" {
  type        = string
  description = "teleport-cluster Helm chart version"
}

variable "service_port" {
  type        = number
  description = "Host port for the Teleport proxy"
  default     = 8443
}

variable "config_oci_url" {
  type        = string
  description = "OCI artifact URL for Teleport config manifests"
}

variable "config_oci_tag" {
  type        = string
  description = "OCI artifact tag for Teleport config manifests"
}

variable "config_substitution_vars" {
  type        = map(string)
  description = "Key-value pairs substituted into the Teleport config manifests by Flux"
  sensitive   = true
}

variable "teleport_cluster_label" {
  type        = string
  description = "Label value for the cluster label that Teleport registers its host Kubernetes cluster with"
}
