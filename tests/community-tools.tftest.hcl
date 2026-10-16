mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "public_tools_keep_signed_reviewed_source_and_secret_gates" {
  command = plan
  assert {
    condition = length(local.community_tools) == 4 && alltrue([
      for name in local.community_tools : (
        github_repository.repositories[name].visibility == "public" &&
        github_repository.repositories[name].has_wiki &&
        one(one(github_repository.repositories[name].security_and_analysis).secret_scanning).status == "enabled" &&
        one(one(github_repository.repositories[name].security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
        github_repository_ruleset.community_tools[name].enforcement == "active" &&
        length(github_repository_ruleset.community_tools[name].bypass_actors) == 0 &&
        one(github_repository_ruleset.community_tools[name].rules).required_signatures &&
        length(one(github_repository_ruleset.community_tools[name].rules).pull_request) == 1 &&
        toset([for check in one(one(github_repository_ruleset.community_tools[name].rules).required_status_checks).required_check : check.context]) == toset(["check", "secrets"])
      )
    ])
    error_message = "Every public tool must retain source and full-history secret gates, signed commits, pull requests, and no bypass actors."
  }
}
