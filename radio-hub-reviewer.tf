# Same repository-scoped reviewer as the public adapters. No admin or bypass role.
# Keep this independent of the repository catalog to avoid unrelated drift.
resource "github_repository_collaborator" "radio_hub_bot" {
  repository = "ha-radio-hub"
  username   = "californiantiramisu"
  permission = "push"
}
