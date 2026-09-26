# Read entitlement from GitHub; this configuration never purchases a subscription.
data "github_organization" "current" {
  name         = "ha-homelab"
  summary_only = true

  lifecycle {
    postcondition {
      condition     = contains(["free", "team", "business", "enterprise"], self.plan)
      error_message = "GitHub must expose a recognized organization plan. Check the administrator credential before planning branch protection."
    }
  }
}

locals {
  private_rulesets_supported = contains(["team", "business", "enterprise"], data.github_organization.current.plan)
  private_repositories = {
    for name, repository in local.repositories : name => repository
    if repository.visibility == "private"
  }

  # Exact successful GitHub Actions check names, verified against each repository.
  required_checks = {
    home-assistant    = ["validate", "maintenance-runtime"]
    automations       = ["Validate automation contracts"]
    scripts           = ["Validate YAML and behavior contracts"]
    home-floorplan-3d = ["validate", "home-assistant"]
  }
}

resource "github_repository_ruleset" "private_main" {
  for_each = local.private_rulesets_supported ? local.private_repositories : {}

  name        = "Protect main"
  repository  = github_repository.repositories[each.key].name
  target      = "branch"
  enforcement = "active"

  # No routine administrator bypass: normal merges must wait for CI as well.
  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true

    pull_request {
      allowed_merge_methods             = ["squash"]
      required_approving_review_count   = 0
      required_review_thread_resolution = true
    }

    required_status_checks {
      strict_required_status_checks_policy = true

      dynamic "required_check" {
        for_each = toset(local.required_checks[each.key])
        content {
          context        = required_check.value
          integration_id = 15368 # GitHub Actions
        }
      }
    }
  }

  lifecycle {
    # A downgrade or inventory edit must not silently remove existing protection.
    prevent_destroy = true
  }
}

output "branch_protection" {
  description = "GitHub plan and private repositories awaiting a plan that supports enforced rulesets."
  value = {
    organization_plan              = data.github_organization.current.plan
    protected_private_repositories = sort(keys(github_repository_ruleset.private_main))
    pending_private_repositories   = local.private_rulesets_supported ? [] : sort(keys(local.private_repositories))
  }
}
