terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.28.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.5.0"
    }
    stripe = {
      source  = "stripe/stripe"
      version = "0.3.0"
    }
  }
}

data "cloudflare_zones" "code0_tech_domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "code0.tech"
}

data "cloudflare_zones" "codezero_build_domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "codezero.build"
}

resource "cloudflare_dns_record" "server_ip" {
  name    = "server_production.code0.tech"
  type    = "A"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = var.server_production_ip
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "server_cname_codezero_build" {
  for_each = toset([
    "cloud.codezero.build",
    "rest-cloud.codezero.build",
    "crater.codezero.build",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.codezero_build_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}
