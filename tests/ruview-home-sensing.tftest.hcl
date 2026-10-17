mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "public_ruview_requires_hosted_ci_and_independent_review" {
  command = plan
  assert {
    condition = (
      github_repository.ruview_home_sensing.visibility == "public" &&
      !github_repository.ruview_home_sensing.auto_init &&
      github_repository.ruview_home_sensing.archive_on_destroy &&
      !github_repository.ruview_home_sensing.allow_auto_merge &&
      one(one(github_repository.ruview_home_sensing.security_and_analysis).secret_scanning).status == "enabled" &&
      one(one(github_repository.ruview_home_sensing.security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
      github_actions_variable.ruview_home_sensing_hosted.value == "github" &&
      github_actions_variable.ruview_home_sensing_hosted.variable_name == "CI_RUNNER_MODE" &&
      github_workflow_repository_permissions.ruview_home_sensing.default_workflow_permissions == "read" &&
      !github_workflow_repository_permissions.ruview_home_sensing.can_approve_pull_request_reviews &&
      github_repository_ruleset.ruview_home_sensing.enforcement == "active" &&
      github_repository_ruleset.ruview_home_sensing_tags.enforcement == "active" &&
      one(github_repository_ruleset.ruview_home_sensing_tags.rules).update &&
      one(github_repository_ruleset.ruview_home_sensing_tags.rules).deletion &&
      length(github_repository_ruleset.ruview_home_sensing_tags.bypass_actors) == 0 &&
      length(github_repository_ruleset.ruview_home_sensing.bypass_actors) == 0 &&
      one(one(github_repository_ruleset.ruview_home_sensing.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.ruview_home_sensing.rules).pull_request).require_last_push_approval &&
      { for check in one(one(github_repository_ruleset.ruview_home_sensing.rules).required_status_checks).required_check : check.context => check.integration_id } == {
        "Public CI gate" = 15368
        "CodeQL"         = 57789
      }
    )
    error_message = "The public RuView implementation must use GitHub-hosted CI, secret protection, a read-only token and independent approval without bypasses."
  }
}
