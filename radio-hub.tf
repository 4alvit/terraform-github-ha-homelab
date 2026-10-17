# Public original source only; firmware credentials and household data stay local.
# Apply after the initial source commit so required checks can run.
data "github_repository_file" "radio_hub_check" {
  repository = github_repository.repositories["ha-radio-hub"].name
  branch     = "main"
  file       = ".github/workflows/check.yml"
}

resource "github_repository_ruleset" "radio_hub" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-radio-hub"].name
  target      = "branch"
  enforcement = "active"

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
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        context        = "check"
        integration_id = 15368
      }
    }
  }
  lifecycle {
    precondition {
      condition     = can(regex("(?m)^  check:", data.github_repository_file.radio_hub_check.content))
      error_message = "Publish the main-branch check workflow before activating radio-hub protection."
    }
  }
  depends_on = [github_branch_default.main]
}
