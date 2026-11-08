variable "docker_name_prefix" {
  description = "Prefix applied to all container, volume and network names."
  type        = string
  default     = ""
}

variable "docker_additional_network_ids" {
  description = <<-EOT
    Optional extra docker networks the OTel collector should join, so
    application containers on those networks can reach it to push OTLP.
  EOT
  type        = list(string)
  default     = []
}

variable "tbot_image" {
  description = "tbot container image (Teleport Machine ID). Pin to the cluster's major version (at most one behind)."
  type = object({
    name          = string
    sha256_digest = string
  })
}

variable "teleport_proxy_address" {
  description = "Teleport Proxy Service address including port."
  type        = string
}

variable "teleport_join_token" {
  description = "Single-use join token for the `token` join method."
  type        = string
  sensitive   = true
}

variable "signoz_app_name" {
  description = "Name of the Teleport app registered for the central SigNoz collector OTLP endpoint."
  type        = string
  default     = "signoz-otlp"
}

variable "otel_collector_image" {
  description = "OpenTelemetry Collector contrib image."
  type = object({
    name          = string
    sha256_digest = string
  })
}

variable "otel_collector_network_aliases" {
  description = "Network aliases to apply to the OpenTelemetry collector container on the additional networks"
  default     = ["opentelemetry-collector"]
}

variable "hostmetrics_scrape_interval" {
  description = "How often the hostmetrics receiver scrapes the host."
  type        = string
  default     = "30s"
}

variable "environment" {
  description = "Value for the deployment.environment attribute"
  type        = string
  default     = null
}

variable "resource_attributes" {
  description = "Resource attributes added onto every metric/trace/log."
  type        = map(string)
  default     = {}
}
