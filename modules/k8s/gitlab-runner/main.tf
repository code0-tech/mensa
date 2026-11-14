terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.5.0"
    }
  }
}

locals {
  manifests = [
    for doc in split("---", templatefile("${path.module}/manifests.yaml.tftpl", {
      namespace     = var.namespace
      chart_version = var.chart_version
      concurrent    = var.concurrent
    })) : yamldecode(trimspace(doc)) if trimspace(doc) != ""
  ]
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_manifest" "this" {
  depends_on = [kubernetes_namespace_v1.this, kubernetes_secret_v1.sensitive_values]

  for_each = { for idx, doc in local.manifests : "${doc.kind}--${doc.metadata.name}" => doc }
  manifest = each.value
}
