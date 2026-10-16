# Independently useful offline tools. All examples are synthetic; public
# repositories contain no deployment credentials or household inventories.
locals {
  community_tools = toset([
    "ha-entity-migrations",
    "ha-meter-contracts",
    "ha-scenario-tests",
    "assist-scenario-lab",
  ])
}

resource "github_repository_ruleset" "community_tools" {
  for_each    = local.community_tools
  name        = "Protect main"
  repository  = github_repository.repositories[each.key].name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion            = true
    non_fast_forward    = true
    required_signatures = true
    pull_request {
      allowed_merge_methods             = ["squash"]
      required_approving_review_count   = 0
      required_review_thread_resolution = true
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        context        = "check"
        integration_id = 15368
      }
      required_check {
        context        = "secrets"
        integration_id = 15368
      }
    }
  }

}
