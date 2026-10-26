mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "public_techo5_dot_has_scoped_review_and_no_device_data" {
  command = plan
  override_resource {
    override_during = plan

    target = github_repository.techo5_dot
    values = {
      repo_id = 424243
    }
  }
  assert {
    condition = (
      github_repository.techo5_dot.name == "ha-techo5-dot" &&
      github_repository.techo5_dot.visibility == "public" &&
      !github_repository.techo5_dot.auto_init &&
      !github_repository.techo5_dot.has_projects &&
      github_repository.techo5_dot.has_wiki &&
      github_repository.techo5_dot.archive_on_destroy &&
      github_repository.techo5_dot.allow_auto_merge &&
      github_repository.techo5_dot.allow_squash_merge &&
      !github_repository.techo5_dot.allow_merge_commit &&
      !github_repository.techo5_dot.allow_rebase_merge &&
      github_repository.techo5_dot.delete_branch_on_merge &&
      one(one(github_repository.techo5_dot.security_and_analysis).secret_scanning).status == "enabled" &&
      one(one(github_repository.techo5_dot.security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
      github_workflow_repository_permissions.techo5_dot.default_workflow_permissions == "read" &&
      github_workflow_repository_permissions.techo5_dot.can_approve_pull_request_reviews &&
      github_repository_collaborator.techo5_dot_bot.repository == "ha-techo5-dot" &&
      github_repository_collaborator.techo5_dot_bot.username == "californiantiramisu" &&
      github_repository_collaborator.techo5_dot_bot.permission == "push" &&
      github_actions_organization_secret_repository.techo5_dot_bot.secret_name == "BOT_PAT" &&
      github_actions_organization_secret_repository.techo5_dot_bot.repository_id == 424243 &&
      github_actions_variable.techo5_dot_hosted.value == "github" &&
      github_actions_variable.techo5_dot_hosted.variable_name == "CI_RUNNER_MODE" &&
      github_repository_dependabot_security_updates.techo5_dot.enabled &&
      github_repository_ruleset.techo5_dot.enforcement == "active" &&
      length(github_repository_ruleset.techo5_dot.bypass_actors) == 0 &&
      one(github_repository_ruleset.techo5_dot.rules).deletion &&
      one(github_repository_ruleset.techo5_dot.rules).non_fast_forward &&
      one(one(github_repository_ruleset.techo5_dot.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.techo5_dot.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.techo5_dot.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.techo5_dot.rules).pull_request).required_review_thread_resolution &&
      one(one(github_repository_ruleset.techo5_dot.rules).required_status_checks).strict_required_status_checks_policy &&
      { for check in one(one(github_repository_ruleset.techo5_dot.rules).required_status_checks).required_check : check.context => check.integration_id } == { "CI gate" = 15368 }
    )
    error_message = "The public TECHO5 repository must retain independent current-head approval, the Actions CI gate, secret protection, hosted runners, and repository-scoped bot access without bypass."
  }
}
