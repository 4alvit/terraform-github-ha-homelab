# CodeRabbit requires the account requesting autofix to have repository write
# access. Public read access is enough to post a comment, but not to run autofix.
resource "github_repository_collaborator" "desloc_coderabbit" {
  for_each = toset(["ha-desloc", "ha-desloc-card"])

  repository = each.key
  username   = "californiantiramisu"
  permission = "push"

  lifecycle {
    precondition {
      condition = (
        data.github_repository.public_software[each.key].visibility == "public" &&
        !data.github_repository.public_software[each.key].archived
      )
      error_message = "CodeRabbit autofix access is limited to active, public DESLOC repositories."
    }
  }
}
