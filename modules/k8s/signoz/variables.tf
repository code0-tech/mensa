variable "chart_version" {
  type        = string
  description = "signoz Helm chart version"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy SigNoz into"
  default     = "signoz"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name of the cluster where SigNoz is running"
}
