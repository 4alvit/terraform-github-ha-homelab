# Independent clean-history public implementation. No private predecessor is
# renamed, imported, or made public by these resources.
resource "github_repository" "ruview_home_sensing" {
  name                   = "ruview-home-sensing"
  description            = "Reusable Wi-Fi sensing, evidence validation, receiver firmware and Home Assistant integration tools"
  visibility             = "public"
  auto_init              = true
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  has_discussions        = false
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  delete_branch_on_merge = true
  archive_on_destroy     = true
  topics                 = ["esp32", "home-assistant", "ruview", "wifi-sensing"]

  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "ruview_home_sensing" {
  repository = github_repository.ruview_home_sensing.name
  branch     = "main"
}

resource "github_workflow_repository_permissions" "ruview_home_sensing" {
  repository                       = github_repository.ruview_home_sensing.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}

# Explicitly override any organization-wide emergency runner routing. Public
# contribution code must never enter an installation's private runner pool.
resource "github_actions_variable" "ruview_home_sensing_hosted" {
  repository    = github_repository.ruview_home_sensing.name
  variable_name = "CI_RUNNER_MODE"
  value         = "github"
}

resource "github_repository_vulnerability_alerts" "ruview_home_sensing" {
  repository = github_repository.ruview_home_sensing.name
}

resource "github_repository_dependabot_security_updates" "ruview_home_sensing" {
  repository = github_repository.ruview_home_sensing.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.ruview_home_sensing]
}

resource "github_repository_ruleset" "ruview_home_sensing" {
  name        = "Protect main"
  repository  = github_repository.ruview_home_sensing.name
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
        context        = "Public CI gate"
        integration_id = 15368
      }
    }
  }
}
