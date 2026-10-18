# Repository-scoped write access lets the existing bot's review satisfy the
# protected branch policy. It grants neither administration nor rule bypass.
locals {
  public_release_review_repositories = toset([
    "home-assistant",
    "home-studio",
    "k3s-self-healing",
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
