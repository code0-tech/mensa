terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
  }
}

locals {
  manifests = [
    for doc in split("---", templatefile("${path.module}/manifests.yaml.tftpl", {
      namespace              = var.namespace
      chart_version          = var.chart_version
      cluster_name           = var.cluster_name
      service_port           = var.service_port
      tls_secret_name        = kubernetes_secret_v1.tls.metadata[0].name
      tls_ca_secret_name     = kubernetes_secret_v1.tls_ca.metadata[0].name
      config_oci_url         = var.config_oci_url
      config_oci_tag         = var.config_oci_tag
      teleport_cluster_label = var.teleport_cluster_label
    })) : yamldecode(trimspace(doc)) if trimspace(doc) != ""
  ]
}

resource "kubernetes_namespace_v1" "this" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "tls" {
  metadata {
    name      = "teleport-tls"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = var.tls_certificate
    "tls.key" = var.tls_private_key
  }
}

resource "kubernetes_secret_v1" "tls_ca" {
  metadata {
    name      = "teleport-tls-ca"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }

  data = {
    "ca.pem" = var.tls_ca_bundle
  }
}

resource "kubernetes_secret_v1" "config_vars" {
  metadata {
    name      = "teleport-config-vars"
    namespace = "flux-system"
  }

  data = var.config_substitution_vars
}

resource "kubernetes_manifest" "this" {
  depends_on = [
    kubernetes_secret_v1.config_vars,
    kubernetes_secret_v1.tls
  ]

  for_each = { for idx, doc in local.manifests : "${doc.kind}--${doc.metadata.name}" => doc }
  manifest = each.value
}
