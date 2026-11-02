# A reusable, public Home Assistant/Asterisk companion. No household configuration,
# SIP credentials, firmware, collaborator grants or runner infrastructure lives here.
resource "github_repository" "asterisk_telephony" {
  name                        = "asterisk-telephony"
  description                 = "Home Assistant integration for Asterisk: verified installer, phone dashboards, call actions, Assist and deployment documentation"
  topics                      = ["home-assistant", "asterisk", "telephony", "sip", "k3s", "python"]
  visibility                  = "public"
  auto_init                   = true
  has_issues                  = true
  has_projects                = false
  has_wiki                    = false
  has_discussions             = false
  allow_merge_commit          = false
  allow_squash_merge          = true
  allow_rebase_merge          = false
  allow_auto_merge            = false
  delete_branch_on_merge      = true
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

resource "github_branch_default" "asterisk_telephony" {
  repository = github_repository.asterisk_telephony.name
  branch     = "main"
}

resource "github_repository_vulnerability_alerts" "asterisk_telephony" {
  repository = github_repository.asterisk_telephony.name
}

resource "github_repository_dependabot_security_updates" "asterisk_telephony" {
  repository = github_repository.asterisk_telephony.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.asterisk_telephony]
}

resource "github_workflow_repository_permissions" "asterisk_telephony" {
  repository                       = github_repository.asterisk_telephony.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}

resource "github_repository_ruleset" "asterisk_telephony" {
  name        = "Asterisk required CI and review"
  repository  = github_repository.asterisk_telephony.name
  target      = "branch"
  enforcement = "active"

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
        context        = "test"
        integration_id = 15368
      }
      required_check {
        context        = "home-assistant-runtime (requirements-runtime.txt)"
        integration_id = 15368
      }
      required_check {
        context        = "home-assistant-runtime (requirements-runtime-2026.10.0.txt)"
        integration_id = 15368
      }
      required_check {
        context        = "CodeQL"
        integration_id = 57789
      }
    }
  }

  depends_on = [github_repository_collaborator.public_release_reviewers["asterisk-telephony"]]

  lifecycle {
    precondition {
      condition     = data.github_repository.public_release_review_targets["asterisk-telephony"].visibility == "public" && !data.github_repository.public_release_review_targets["asterisk-telephony"].archived
      error_message = "The Asterisk review policy applies only to its active public repository."
    }
  }
}

output "asterisk_telephony_repository" {
  description = "Public reusable Asterisk/Home Assistant companion repository."
  value = {
    html_url   = github_repository.asterisk_telephony.html_url
    ssh_url    = github_repository.asterisk_telephony.ssh_clone_url
    visibility = github_repository.asterisk_telephony.visibility
  }
}
