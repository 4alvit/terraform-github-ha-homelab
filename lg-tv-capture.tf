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

resource "github_repository_ruleset" "lg_tv_capture_release_tags" {
  name        = "Release standard - immutable version tags"
  repository  = github_repository.repositories["ha-lg-tv-capture"].name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    update           = true
    non_fast_forward = true
  }
}

resource "github_repository_environment" "lg_tv_capture_release" {
  repository  = github_repository.repositories["ha-lg-tv-capture"].name
  environment = "release"
  # Match the existing single-maintainer release approval policy.
  prevent_self_review = false
  can_admins_bypass   = true

  reviewers {
    users = [272257197] # 4alvit
  }

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "lg_tv_capture_release" {
  repository     = github_repository.repositories["ha-lg-tv-capture"].name
  environment    = github_repository_environment.lg_tv_capture_release.environment
  branch_pattern = "main"
}

# Activate only after the source PR is merged and its workflow checks pass.
resource "github_actions_variable" "lg_tv_capture_release_publication" {
  repository    = github_repository.repositories["ha-lg-tv-capture"].name
  variable_name = "RELEASE_CHANNELS_ENABLED"
  value         = "true"

  depends_on = [
    github_repository_ruleset.lg_tv_capture,
    github_repository_ruleset.lg_tv_capture_release_tags,
    github_repository_environment_deployment_policy.lg_tv_capture_release,
  ]
}
