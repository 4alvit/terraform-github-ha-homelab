# Public software explicitly audited for the OpenSSF rollout. Private and archived
# repositories are excluded using live visibility before new rules are created.
locals {
  public_software_repositories = toset([
    "ha-desloc",
    "ha-desloc-card",
    "ha-echo-dot",
    "ha-echo-show-5",
    "rf-airbridge",
    "slzb-06-recovery"
  ])
  public_missing_review_repositories = toset([])
}

data "github_repository" "public_software" {
  for_each  = local.public_software_repositories
  full_name = "ha-homelab/${each.value}"
}

locals {
  active_public_software_repositories = toset([
    for repo, metadata in data.github_repository.public_software : repo
    if metadata.visibility == "public" && !metadata.archived
  ])
}

resource "github_repository_ruleset" "public_review" {
  for_each = toset([
    for repo in local.public_missing_review_repositories : repo
    if data.github_repository.public_software[repo].visibility == "public" && !data.github_repository.public_software[repo].archived
  ])
  name        = "Public software - required review"
  repository  = each.value
  target      = "branch"
  enforcement = "active"
  # Intentionally no bypass actors, including administrators and automation apps.
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
      required_approving_review_count   = 2
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
  }
}
