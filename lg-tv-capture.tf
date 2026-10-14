# Apply the repository first, publish reviewed source through a PR, then activate
# this ruleset once the source workflow provides the required CI gate check.
resource "github_repository_ruleset" "lg_tv_capture" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-lg-tv-capture"].name
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
        context        = "CI gate"
        integration_id = 15368
      }
    }
  }

  depends_on = [github_branch_default.main["ha-lg-tv-capture"]]
}

resource "github_workflow_repository_permissions" "lg_tv_capture" {
  repository                       = github_repository.repositories["ha-lg-tv-capture"].name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = true
}
