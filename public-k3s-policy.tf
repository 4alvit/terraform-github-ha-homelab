# Protect the existing public source repository without managing its contents.
resource "github_repository_ruleset" "public_k3s" {
  name        = "Protect main"
  repository  = data.github_repository.public_release_review_targets["k3s-self-healing"].name
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

  lifecycle {
    precondition {
      condition = (
        data.github_repository.public_release_review_targets["k3s-self-healing"].visibility == "public" &&
        !data.github_repository.public_release_review_targets["k3s-self-healing"].archived
      )
      error_message = "This policy applies only to the active public k3s source repository."
    }
  }
}
