# Repository-scoped write access lets the existing bot's review satisfy the
# protected branch policy. It grants neither administration nor rule bypass.
locals {
  public_release_review_repositories = toset([
    ".github",
    "assist-scenario-lab",
    "ha-echo-dot",
    "ha-echo-show-5",
    "ha-entity-migrations",
    "ha-jbd-bms-card",
    "ha-meter-contracts",
    "ha-scenario-tests",
    "home-assistant",
    "home-studio",
    "k3s-self-healing",
    "rf-airbridge",
    "slzb-06-recovery",
    "zac93-esp32",
  ])
}

data "github_repository" "public_release_review_targets" {
  for_each  = local.public_release_review_repositories
  full_name = "ha-homelab/${each.key}"
}

resource "github_repository_collaborator" "public_release_reviewers" {
  for_each   = local.public_release_review_repositories
  repository = each.key
  username   = "californiantiramisu"
  permission = "push"

  lifecycle {
    precondition {
      condition = (
        data.github_repository.public_release_review_targets[each.key].visibility == "public" &&
        !data.github_repository.public_release_review_targets[each.key].archived
      )
      error_message = "Review access is limited to the explicitly listed active public repositories."
    }
  }
}
