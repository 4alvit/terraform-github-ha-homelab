# Bootstrap the repository/default branch/security resources first, publish the
# reviewed card source and its CI gate, then activate this final branch policy.
# No existing repository's rules are relaxed during this two-stage creation.
resource "github_repository_ruleset" "jbd_bms_card" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-jbd-bms-card"].name
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

  depends_on = [github_branch_default.main["ha-jbd-bms-card"]]
}

resource "github_workflow_repository_permissions" "jbd_bms_card" {
  repository                       = github_repository.repositories["ha-jbd-bms-card"].name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}
