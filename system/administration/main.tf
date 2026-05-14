terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.1"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.9.0"
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

module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "outline.code0.tech",
    "codezero.build"
  ]
}

module "outline" {
  source = "../../modules/docker/outline"

  web_url                 = "outline.code0.tech"
  docker_proxy_network_id = module.proxy.docker_proxy_network_id
}

module "cygnus" {
  source = "../../modules/docker/cygnus"

  web_urls                = ["codezero.build"]
  docker_proxy_network_id = module.proxy.docker_proxy_network_id
}

module "pyxis" {
  source = "../../modules/docker/pyxis"
}

resource "cloudflare_dns_record" "server_ip" {
  name    = "server_administration.code0.tech"
  type    = "A"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = var.server_administration_ip
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "server_cname_code0_tech" {
  for_each = toset([
    "outline.code0.tech",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "server_cname_codezero_build" {
  for_each = toset([
    "codezero.build",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.codezero_build_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}
