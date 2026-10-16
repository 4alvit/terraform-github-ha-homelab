# Home Studio already exists. Own only its required CI ruleset here; importing
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

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    pull_request {
      required_approving_review_count = 0
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
