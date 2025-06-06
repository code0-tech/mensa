terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.5.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.4.0"
    }
  }
}

data "cloudflare_zones" "main_domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "code0.tech"
}

module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "plane.code0.tech",
    "outline.code0.tech",
  ]
}

module "plane" {
  source = "../../modules/docker/plane"

  web_url                 = "plane.code0.tech"
  docker_proxy_network_id = module.proxy.docker_proxy_network_id
}

module "outline" {
  source = "../../modules/docker/outline"

  web_url                 = "outline.code0.tech"
  docker_proxy_network_id = module.proxy.docker_proxy_network_id
}

resource "cloudflare_dns_record" "server_ip" {
  name    = "server_administration.code0.tech"
  type    = "A"
  ttl     = 1
  zone_id = data.cloudflare_zones.main_domain.result[0].id
  content = var.server_administration_ip
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "server_cname" {
  for_each = toset([
    "plane.code0.tech",
    "outline.code0.tech",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.main_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}
