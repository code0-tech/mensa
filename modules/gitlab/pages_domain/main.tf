terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.5.0"
    }
    gitlab = {
      source = "gitlabhq/gitlab"
      version = "18.0.0"
    }
  }
}

//noinspection MissingProperty
data "gitlab_project" "this" {
  path_with_namespace = var.gitlab_project_path
}

resource "cloudflare_dns_record" "gitlab_pages" {
  name     = var.cloudflare_domain_name
  type     = "CNAME"
  ttl      = 1
  zone_id  = var.cloudflare_zone_id
  content  = var.gitlab_unique_pages_url
  proxied  = true
  comment  = "Managed by Terraform"
}

module "certificate" {
  source = "../../cloudflare/certificate"

  hostname = cloudflare_dns_record.gitlab_pages.name
}

data "http" "cloudflare_root" {
  url = "https://developers.cloudflare.com/ssl/static/origin_ca_rsa_root.pem"

  retry {
    attempts = 2
  }
}

resource "gitlab_pages_domain" "this" {
  project = data.gitlab_project.this.id
  domain  = cloudflare_dns_record.gitlab_pages.name

  key         = module.certificate.private_key
  certificate = <<-EOF
    ${module.certificate.certificate}
    ${data.http.cloudflare_root.response_body}
  EOF
}

//noinspection HILUnresolvedReference
resource "cloudflare_dns_record" "gitlab_pages_verification" {
  name = "_gitlab-pages-verification-code.${var.cloudflare_domain_name}"
  type = "TXT"
  ttl     = 1
  zone_id = var.cloudflare_zone_id
  content = gitlab_pages_domain.this.verification_code
  comment  = "Managed by Terraform | Pages verification for ${cloudflare_dns_record.gitlab_pages.name}"
}
