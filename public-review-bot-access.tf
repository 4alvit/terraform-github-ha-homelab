# Add six missing memberships to the existing selected-repository secret.
# Do not own its value, visibility, or the memberships of other repositories.
locals {
  public_review_bot_access_repositories = toset([
    "assist-scenario-lab",
    "ha-entity-migrations",
    "ha-meter-contracts",
    "ha-scenario-tests",
    "home-studio",
    "zac93-esp32",
  ])
}

resource "github_actions_organization_secret_repository" "public_review_bot_access" {
  for_each      = local.public_review_bot_access_repositories
  secret_name   = "BOT_PAT"
  repository_id = data.github_repository.public_release_review_targets[each.key].repo_id

  lifecycle {
    precondition {
      condition = (
        data.github_repository.public_release_review_targets[each.key].visibility == "public" &&
        !data.github_repository.public_release_review_targets[each.key].archived
      )
      error_message = "Review credential access is limited to the six declared active public repositories."
    }
  }
}
