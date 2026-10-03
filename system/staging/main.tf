terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.25.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.6.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "19.4.0"
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

resource "cloudflare_dns_record" "server_cname_codezero_build" {
  for_each = toset([
    "crater-staging.codezero.build",
  ])

  name    = each.value
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.codezero_build_domain.result[0].id
  content = cloudflare_dns_record.server_ip.name
  proxied = true

  comment = "Managed by Terraform"
}

module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "signoz.code0.tech",
    "crater-staging.codezero.build",
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

module "stripe_config" {
  source = "git::ssh://git@github.com/code0-tech/mensa-private//modules/stripe/config?ref=3fa16a3d01b45ba22560eb59ba3597c5a739d800"
}

data "docker_registry_image" "crater" {
  name = "registry.gitlab.com/code0-tech/development/crater:2909547162"
}

data "gitlab_project_secure_file" "license_encryption_key" {
  project = "code0-tech/secret-manager"
  name    = "license_encryption_key_production.key"
}

module "crater" {
  source = "git::ssh://git@github.com/code0-tech/mensa-private//modules/docker/crater?ref=7f79a230f9d938eeb844dc02fc50597b29bf679b"

  docker_name_prefix = "staging-"
  virtual_host       = "crater-staging.codezero.build"
  crater_image = {
    name          = data.docker_registry_image.crater.name
    sha256_digest = data.docker_registry_image.crater.sha256_digest
  }
  additional_crater_config = {}
  license_encryption_key = data.gitlab_project_secure_file.license_encryption_key.content
}

# data "docker_registry_image" "cygnus" {
#   name = "ghcr.io/code0-tech/cygnus:2141"
# }
#
# module "cygnus" {
#   source = "../../modules/docker/cygnus"
#
#   web_urls                = ["codezero.build"]
#   docker_proxy_network_id = module.proxy.docker_proxy_network_id
#   cygnus_image = {
#     name = data.docker_registry_image.cygnus.name
#     sha256_digest = data.docker_registry_image.cygnus.sha256_digest
#   }
# }
