variable "cluster_name" {
  type        = string
  description = "Teleport cluster name (must be a FQDN, cannot be changed after initial deploy)"
}

variable "chart_version" {
  type        = string
  description = "teleport-cluster Helm chart version"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy Teleport into"
  default     = "teleport"
}

variable "tls_certificate" {
  type        = string
  description = "TLS certificate PEM for the Teleport proxy (Cloudflare origin cert)"
  sensitive   = true
}

variable "tls_ca_bundle" {
  type        = string
  description = "CA bundle Teleport trusts on startup (Cloudflare Origin CA root + public Mozilla CA bundle). Loaded via SSL_CERT_FILE using tls.existingCASecretName. Must include public CAs since it fully replaces the image trust store."
}

variable "tls_private_key" {
  type        = string
  description = "TLS private key PEM for the Teleport proxy"
  sensitive   = true
}

variable "service_port" {
  type        = number
  description = "Host port for the Teleport proxy LoadBalancer service"
  default     = 8443
}

variable "config_oci_url" {
  type        = string
  description = "OCI artifact URL for Teleport config manifests (e.g. oci://ghcr.io/code0-tech/mensa/teleport-config)"
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
