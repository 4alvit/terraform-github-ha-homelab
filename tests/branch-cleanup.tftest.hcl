mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "all_managed_repositories_delete_merged_branches" {
  command = plan
  assert {
    condition = alltrue(concat(
      [for repository in github_repository.repositories : repository.delete_branch_on_merge],
      [for repository in github_repository.public_adapters : repository.delete_branch_on_merge],
      [
        github_repository.asterisk_telephony.delete_branch_on_merge,
        github_repository.techo5_dot.delete_branch_on_merge,
        github_repository.home_assistant_public.delete_branch_on_merge,
        github_repository.cloudflare_home_assistant.delete_branch_on_merge,
        github_repository.ruview_home_sensing.delete_branch_on_merge,
      ],
    ))
    error_message = "Every managed repository must delete eligible merged pull-request branches."
  }
}
