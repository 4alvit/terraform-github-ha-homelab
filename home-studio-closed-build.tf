# Closed release processing runs in the public workflow, but credentials are
# released only to reviewed main-branch jobs. Secret values and storage URLs
# are deliberately managed by the operator outside Terraform state.
resource "github_repository_environment" "home_studio_closed_build" {
  repository          = data.github_repository.home_studio.name
  environment         = "closed-build"
  can_admins_bypass   = false
  prevent_self_review = false

  reviewers {
    users = [272257197] # Existing release owner (4alvit).
  }

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "home_studio_closed_main" {
  repository     = data.github_repository.home_studio.name
  environment    = github_repository_environment.home_studio_closed_build.environment
  branch_pattern = "main"
}

