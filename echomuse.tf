# Bootstrap the repository and its security settings first. Publish reviewed
# source and verify its CI gate before activating this branch protection.
resource "github_repository_ruleset" "echomuse" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-echomuse"].name
  target      = "branch"
  enforcement = "active"

  # Organization owners may bypass this branch rule for maintenance.
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

  depends_on = [github_branch_default.main["ha-echomuse"]]
}

# The shared metadata workflows approve trusted authors with an independent
# identity. They never execute pull-request source with this credential.
resource "github_workflow_repository_permissions" "echomuse" {
  repository                       = github_repository.repositories["ha-echomuse"].name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = true
}

data "github_repository" "echomuse_access" {
  full_name = "ha-homelab/ha-echomuse"
}

resource "github_repository_collaborator" "echomuse_bot" {
  repository = github_repository.repositories["ha-echomuse"].name
  username   = "californiantiramisu"
  permission = "push"

  lifecycle {
    precondition {
      condition = (
        data.github_repository.echomuse_access.visibility == "public" &&
        !data.github_repository.echomuse_access.archived
      )
      error_message = "EchoMuse bot access is limited to its active public repository."
    }
  }
}

# Add only EchoMuse to the existing secret allowlist; do not manage its value
# or replace grants belonging to other repositories.
resource "github_actions_organization_secret_repository" "echomuse_bot_pat" {
  secret_name   = "BOT_PAT"
  repository_id = data.github_repository.echomuse_access.repo_id

  lifecycle {
    precondition {
      condition = (
        data.github_repository.echomuse_access.visibility == "public" &&
        !data.github_repository.echomuse_access.archived
      )
      error_message = "EchoMuse bot credential access is limited to its active public repository."
    }
  }
}
