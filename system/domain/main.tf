terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.1"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.11.0"
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

resource "cloudflare_zone_setting" "zone_settings_code0_tech" {
  for_each = {
    ssl = "strict"
  }

  zone_id    = data.cloudflare_zones.code0_tech_domain.result[0].id
  setting_id = each.key
  value      = each.value
}

resource "cloudflare_zone_setting" "zone_settings_codezero_build" {
  for_each = {
    ssl = "strict"
  }

  zone_id    = data.cloudflare_zones.codezero_build_domain.result[0].id
  setting_id = each.key
  value      = each.value
}

module "docs_pages_code0_tech" {
  source = "../../modules/gitlab/pages_domain"

  cloudflare_domain_name  = "docs.code0.tech"
  cloudflare_zone_id      = data.cloudflare_zones.code0_tech_domain.result[0].id
  gitlab_project_path     = "code0-tech/development/telescopium"
  gitlab_unique_pages_url = "docs-code0-tech-c91f18c0d2259c041bf05138b194e6bb082059fe38eff2e.gitlab.io"
}

module "docs_pages_codezero_build" {
  source = "../../modules/gitlab/pages_domain"

  cloudflare_domain_name  = "docs.codezero.build"
  cloudflare_zone_id      = data.cloudflare_zones.codezero_build_domain.result[0].id
  gitlab_project_path     = "code0-tech/development/telescopium"
  gitlab_unique_pages_url = "docs-code0-tech-c91f18c0d2259c041bf05138b194e6bb082059fe38eff2e.gitlab.io"
}

resource "cloudflare_dns_record" "github_verification_code0_tech" {
  name    = "_github-challenge-code0-tech-org.code0.tech"
  type    = "TXT"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = "e3447326f4"
  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "github_verification_codezero_build" {
  name    = "_gh-code0-tech-o.codezero.build"
  type    = "TXT"
  ttl     = 1
  zone_id = data.cloudflare_zones.codezero_build_domain.result[0].id
  content = "5a9b0d31a8"
  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "strato_spf" {
  name    = "code0.tech"
  type    = "TXT"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = "v=spf1 redirect=smtp.strato.de"
  comment = "Managed by Terraform"
}

resource "cloudflare_dns_record" "strato_dkim" {
  name    = "strato-dkim-0002._domainkey.code0.tech"
  type    = "CNAME"
  ttl     = 1
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id
  content = "strato-dkim-0002._domainkey.strato.de"
  comment = "Managed by Terraform"
}

resource "cloudflare_ruleset" "redirects_code0_tech" {
  kind    = "zone"
  name    = "redirects"
  phase   = "http_request_dynamic_redirect"
  zone_id = data.cloudflare_zones.code0_tech_domain.result[0].id

  rules = [
    {
      ref        = "redirect_to_codezero_build"
      expression = "(http.host eq \"code0.tech\")"
      action     = "redirect"
      action_parameters = {
        from_value = {
          status_code = 301
          target_url = {
            expression = "concat(\"https://codezero.build\", http.request.uri)"
          }
          preserve_query_string = true
        }
      }
    },
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
    },
  ]
}

resource "cloudflare_ruleset" "redirects_codezero_build" {
  kind    = "zone"
  name    = "redirects"
  phase   = "http_request_dynamic_redirect"
  zone_id = data.cloudflare_zones.codezero_build_domain.result[0].id

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
    },
  ]
}
