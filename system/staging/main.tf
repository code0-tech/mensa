terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.23.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.5.0"
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
  name    = "server_staging.code0.tech"
  type    = "A"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = var.server_staging_ip
  proxied = true

  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "server_cname_code0_tech" {
  for_each = toset([
    "signoz.code0.tech",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}

module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "signoz.code0.tech",
  ]
}

resource "random_password" "codezero_initial_root_password" {
  length  = 32
  special = false
}

module "codezero" {
  source = "github.com/code0-tech/reticulum//terraform/docker?ref=161d4aba28edbbfd795a7135a004bc43ea59432b"

  hostname              = "staging.codezero.build"
  initial_root_mail     = "root@code0.tech"
  initial_root_password = random_password.codezero_initial_root_password.result
  image_tag             = "0.0.0-canary-2821608682-64f60183ed488c060e58140d9fac1f4f59fa3a74"
  image_edition         = "cloud"
  image_registry        = "ghcr.io/code0-tech/reticulum/ci-builds"

  http_port     = 15242
  https_port    = null
  nginx_bind_ip = "127.0.0.1"
}

module "signoz" {
  source = "../../modules/docker/signoz"

  proxy_network = module.proxy.docker_proxy_network_name
  hostname      = "signoz.code0.tech"
}
