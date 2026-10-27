# Reusable public module only: no account identifiers, domains, state, credentials
# or existing deployment configuration is imported or published here.
resource "github_repository" "cloudflare_home_assistant" {
  name                   = "terraform-cloudflare-home-assistant"
  description            = "Reusable Terraform for publishing Home Assistant through Cloudflare Tunnel with private deployment inputs"
  visibility             = "public"
  auto_init              = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  has_discussions        = false
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
  topics                 = ["terraform", "cloudflare", "cloudflare-tunnel", "home-assistant", "homelab", "zero-trust"]

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

resource "github_branch_default" "cloudflare_home_assistant" {
  repository = github_repository.cloudflare_home_assistant.name
  branch     = "main"
}

resource "github_workflow_repository_permissions" "cloudflare_home_assistant" {
  repository                       = github_repository.cloudflare_home_assistant.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = true
}

# Metadata-only shared workflows use this independent reviewer; no bypass or
# administrator role is granted and no credential value is managed here.
resource "github_repository_collaborator" "cloudflare_home_assistant_bot" {
  repository = github_repository.cloudflare_home_assistant.name
  username   = "californiantiramisu"
  permission = "push"
}

resource "github_actions_organization_secret_repository" "cloudflare_home_assistant_bot" {
  secret_name   = "BOT_PAT"
  repository_id = github_repository.cloudflare_home_assistant.repo_id
}

resource "github_issue_label" "cloudflare_home_assistant_automerge" {
  repository  = github_repository.cloudflare_home_assistant.name
  name        = "automerge"
  color       = "0e8a16"
  description = "Merge only after current-head approval and all required validation"
}

resource "github_issue_label" "cloudflare_home_assistant_autoapprove" {
  repository  = github_repository.cloudflare_home_assistant.name
  name        = "auto-approve"
  color       = "2da44e"
  description = "Request the shared independent-reviewer approval policy"
}

# Explicitly override any organization-wide emergency runner routing. Public
# contribution code must never enter an installation's private runner pool.
resource "github_actions_variable" "cloudflare_home_assistant_hosted" {
  repository    = github_repository.cloudflare_home_assistant.name
  variable_name = "CI_RUNNER_MODE"
  value         = "github"
}

resource "github_repository_vulnerability_alerts" "cloudflare_home_assistant" {
  repository = github_repository.cloudflare_home_assistant.name
}

resource "github_repository_dependabot_security_updates" "cloudflare_home_assistant" {
  repository = github_repository.cloudflare_home_assistant.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.cloudflare_home_assistant]
}

resource "github_repository_ruleset" "cloudflare_home_assistant" {
  name        = "Protect main"
  repository  = github_repository.cloudflare_home_assistant.name
  target      = "branch"
  enforcement = "active"

  # Owners may make an explicit emergency merge through an auditable PR.
  bypass_actors {
    actor_id    = local.owner_emergency_merge_actor.actor_id
    actor_type  = local.owner_emergency_merge_actor.actor_type
    bypass_mode = local.owner_emergency_merge_actor.bypass_mode
  }

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

  depends_on = [github_branch_default.cloudflare_home_assistant]
}
