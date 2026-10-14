# Bootstrap the repository and its security settings first. Publish reviewed
# source and verify its CI gate before activating this branch protection.
resource "github_repository_ruleset" "echomuse" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-echomuse"].name
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

  depends_on = [github_branch_default.main["ha-echomuse"]]
}
