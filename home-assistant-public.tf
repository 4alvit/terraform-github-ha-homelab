# This is a NEW repository, not a visibility change on the private predecessor.
# Apply only after the existing repository has been renamed, then push the
# reviewed one-commit source snapshot before configuring its default branch.
resource "github_repository" "home_assistant_public" {
  name        = "home-assistant"
  description = "Home Assistant configuration, bundled automation and script libraries, deployment guidance, and integration contracts"
  visibility  = "public"
  topics      = ["home-assistant", "home-automation", "k3s", "kubernetes"]

  auto_init       = false
  has_issues      = true
  has_projects    = false
  has_wiki        = false
  has_discussions = false

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  delete_branch_on_merge = true

  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
  archive_on_destroy          = true

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

resource "github_workflow_repository_permissions" "home_assistant_public" {
  repository                   = github_repository.home_assistant_public.name
  default_workflow_permissions = "read"
  # Only explicitly opted-in PRs receive approval in the repository CI workflow.
  can_approve_pull_request_reviews = true
}

resource "github_repository_vulnerability_alerts" "home_assistant_public" {
  repository = github_repository.home_assistant_public.name
}

resource "github_repository_dependabot_security_updates" "home_assistant_public" {
  repository = github_repository.home_assistant_public.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.home_assistant_public]
}

# Apply these after the reviewed root commit has populated the empty repository.
resource "github_branch_default" "home_assistant_public" {
  repository = github_repository.home_assistant_public.name
  branch     = "main"
}

resource "github_repository_ruleset" "home_assistant_public" {
  name        = "Protect main"
  repository  = github_repository.home_assistant_public.name
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
        context        = "validate"
        integration_id = 15368
      }
      required_check {
        context        = "maintenance-runtime"
        integration_id = 15368
      }
    }
  }

  depends_on = [github_branch_default.home_assistant_public]
}
