terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.23.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.1"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

data "http" "cloudflare_origin_ca_root" {
  url = "https://developers.cloudflare.com/ssl/static/origin_ca_rsa_root.pem"

  retry {
    attempts = 2
  }
}

# Public CA bundle (Mozilla PKI). Required because tls.existingCASecretName fully
# replaces Teleport's built-in trust store, and Teleport still needs to trust public
# CAs for GitHub OAuth, Let's Encrypt, etc.
data "http" "mozilla_ca_bundle" {
  url = "https://curl.se/ca/cacert.pem"

  retry {
    attempts = 2
  }
}

data "cloudflare_zones" "code0_tech" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "code0.tech"
}

module "certificate" {
  source   = "../../modules/cloudflare/certificate"
  hostname = var.hostname
}

module "teleport" {
  source = "../../modules/k8s/teleport"

  cluster_name             = var.hostname
  chart_version            = var.chart_version
  tls_certificate          = module.certificate.certificate
  tls_ca_bundle            = "${trimspace(data.http.cloudflare_origin_ca_root.response_body)}\n${trimspace(data.http.mozilla_ca_bundle.response_body)}\n"
  tls_private_key          = module.certificate.private_key
  service_port             = var.service_port
  config_oci_url           = var.config_oci_url
  config_oci_tag           = var.config_oci_tag
  config_substitution_vars = var.config_substitution_vars
  teleport_cluster_label   = var.teleport_cluster_label
}

resource "cloudflare_dns_record" "teleport" {
  name    = var.hostname
  type    = "A"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech.result[0].id
  content = var.server_ip
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_ruleset" "origin_rules" {
  kind    = "zone"
  name    = "Origin rules"
  phase   = "http_request_origin"
  zone_id = data.cloudflare_zones.code0_tech.result[0].id

  rules = [{
    action = "route"
    action_parameters = {
      origin = {
        port = var.service_port
      }
    }
    expression = "(http.host eq \"${var.hostname}\")"
    enabled    = true
  }]
}
