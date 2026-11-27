resource "github_repository_ruleset" "cla_rule" {
  for_each = toset(data.github_repositories.active_public_repositories.names)
  name = "CLA"
  repository = each.value
  target = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  bypass_actors {
    // code0-release-tools
    actor_id    = 857194
    actor_type  = "Integration"
    bypass_mode = "exempt"
  }

  bypass_actors {
    // code0-terraform-administration
    actor_id    = 832219
    actor_type  = "Integration"
    bypass_mode = "exempt"
  }

  rules {
    required_status_checks {
      required_check {
        context = "license/cla"
      }
    }
  }
}
