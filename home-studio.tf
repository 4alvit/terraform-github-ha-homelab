# Home Studio already exists. Own only its review/CI ruleset here; importing
# repository settings, collaborators and release configuration is separate work.
data "github_repository" "home_studio" {
  full_name = "ha-homelab/home-studio"

  lifecycle {
    postcondition {
      condition     = self.visibility == "public" && !self.archived
      error_message = "Home Studio CI enforcement applies only to the active public repository."
    }
  }
}

resource "github_repository_ruleset" "home_studio_ci" {
  name        = "Require Home Studio CI"
  repository  = data.github_repository.home_studio.name
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
    pull_request {
      dismiss_stale_reviews_on_push   = true
      require_last_push_approval      = true
      required_approving_review_count = 1
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        # Verified against the public Quality gate run, including app identity.
        context        = "CI gate"
        integration_id = 15368
      }
    }
  }
}
