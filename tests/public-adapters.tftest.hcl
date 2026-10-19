mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "public_adapters_require_review_checks_and_secret_protection" {
  command = plan
  assert {
    condition = toset(keys(github_repository.public_adapters)) == toset([
      "ha-ottplay", "ha-onvif-room-direction", "ruview-home-assistant",
      "ha-access-session", "sensing-evidence-kit"
      ]) && alltrue([
      for name, repository in github_repository.public_adapters : (
        repository.visibility == "public" &&
        repository.allow_auto_merge &&
        one(one(repository.security_and_analysis).secret_scanning).status == "enabled" &&
        one(one(repository.security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
        github_repository_ruleset.public_adapters[name].enforcement == "active" &&
        length(github_repository_ruleset.public_adapters[name].bypass_actors) == 0 &&
        one(one(github_repository_ruleset.public_adapters[name].rules).pull_request).required_approving_review_count == 1 &&
        one(one(github_repository_ruleset.public_adapters[name].rules).pull_request).require_last_push_approval &&
        toset([for check in one(one(github_repository_ruleset.public_adapters[name].rules).required_status_checks).required_check : check.context]) == toset(["CI gate"]) &&
        github_repository_collaborator.public_adapters_bot[name].permission == "push" &&
        github_actions_organization_secret_repository.public_adapters_bot[name].secret_name == "BOT_PAT" &&
        one(github_repository_ruleset.public_adapters_tags[name].rules).update &&
        one(github_repository_ruleset.public_adapters_tags[name].rules).deletion &&
        github_repository_environment_deployment_policy.public_adapters_release[name].branch_pattern == "main"
      )
    ])
    error_message = "Every public adapter, including OTTPlay, requires secret protection, independent review, CI, immutable version tags and main-only releases."
  }
}
