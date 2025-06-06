terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.5.0"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.0.0"
    }
  }
}

data "cloudflare_zones" "main_domain" {
  account = {
    id = var.cloudflare_account_id
  }
  name = "code0.tech"
}

resource "cloudflare_zone_setting" "zone_settings" {
  for_each = {
    ssl = "strict"
  }

  zone_id    = data.cloudflare_zones.main_domain.result[0].id
  setting_id = each.key
  value      = each.value
}

module "docs_pages" {
  source = "../../modules/gitlab/pages_domain"

  cloudflare_domain_name  = "docs.code0.tech"
  cloudflare_zone_id      = data.cloudflare_zones.main_domain.result[0].id
  gitlab_project_path     = "code0-tech/development/telescopium"
  gitlab_unique_pages_url = "docs-code0-tech-c91f18c0d2259c041bf05138b194e6bb082059fe38eff2e.gitlab.io"
}

module "landing_page_pages" {
  source = "../../modules/gitlab/pages_domain"

  cloudflare_domain_name  = "code0.tech"
  cloudflare_zone_id      = data.cloudflare_zones.main_domain.result[0].id
  gitlab_project_path     = "code0-tech/development/landing-page"
  gitlab_unique_pages_url = "landing-page-code0-tech-development-b2dc2848e053fa1893b1dfbb1ba.gitlab.io"
}

resource "cloudflare_dns_record" "github_verification" {
  name    = "_github-challenge-code0-tech-org.code0.tech"
  type    = "TXT"
  ttl     = 1
  zone_id = data.cloudflare_zones.main_domain.result[0].id
  content = "e3447326f4"
  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "strato_spf" {
  name    = "code0.tech"
  type    = "TXT"
  ttl     = 1
  zone_id = data.cloudflare_zones.main_domain.result[0].id
  content = "v=spf1 redirect=smtp.strato.de"
  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "strato_dkim" {
  name    = "strato-dkim-0002._domainkey.code0.tech"
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.main_domain.result[0].id
  content = "strato-dkim-0002._domainkey.strato.de"
  comment = "Managed by Terraform"
}

resource "cloudflare_ruleset" "force_https" {
  kind    = "zone"
  name    = "force_https"
  phase   = "http_request_dynamic_redirect"
  zone_id = data.cloudflare_zones.main_domain.result[0].id

  rules = [
    {
      ref        = "redirect_http"
      expression = "(http.request.full_uri wildcard r\"http://*\")"
      action     = "redirect"
      action_parameters = {
        from_value = {
          status_code = 302
          target_url = {
            expression = "wildcard_replace(http.request.full_uri, \"http://*\", \"https://${"$"}{1}\")"
          }
          preserve_query_string = true
        }
      }
    }
  ]
}
