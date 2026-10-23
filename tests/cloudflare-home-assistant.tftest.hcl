mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "public_cloudflare_module_has_scoped_review_and_no_deployment_data" {
  command = plan
  override_resource {
    override_during = plan

    target = github_repository.cloudflare_home_assistant
    values = {
      repo_id = 424243
    }
  }
  assert {
    condition = (
      github_repository.cloudflare_home_assistant.name == "terraform-cloudflare-home-assistant" &&
      github_repository.cloudflare_home_assistant.visibility == "public" &&
      !github_repository.cloudflare_home_assistant.auto_init &&
      !github_repository.cloudflare_home_assistant.has_projects &&
      !github_repository.cloudflare_home_assistant.has_wiki &&
      github_repository.cloudflare_home_assistant.archive_on_destroy &&
      github_repository.cloudflare_home_assistant.allow_auto_merge &&
      github_repository.cloudflare_home_assistant.allow_squash_merge &&
      !github_repository.cloudflare_home_assistant.allow_merge_commit &&
      !github_repository.cloudflare_home_assistant.allow_rebase_merge &&
      github_repository.cloudflare_home_assistant.delete_branch_on_merge &&
      one(one(github_repository.cloudflare_home_assistant.security_and_analysis).secret_scanning).status == "enabled" &&
      one(one(github_repository.cloudflare_home_assistant.security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
      github_workflow_repository_permissions.cloudflare_home_assistant.default_workflow_permissions == "read" &&
      github_workflow_repository_permissions.cloudflare_home_assistant.can_approve_pull_request_reviews &&
      github_repository_collaborator.cloudflare_home_assistant_bot.repository == "terraform-cloudflare-home-assistant" &&
      github_repository_collaborator.cloudflare_home_assistant_bot.username == "californiantiramisu" &&
      github_repository_collaborator.cloudflare_home_assistant_bot.permission == "push" &&
      github_actions_organization_secret_repository.cloudflare_home_assistant_bot.secret_name == "BOT_PAT" &&
      github_actions_organization_secret_repository.cloudflare_home_assistant_bot.repository_id == 424243 &&
      github_actions_variable.cloudflare_home_assistant_hosted.value == "github" &&
      github_actions_variable.cloudflare_home_assistant_hosted.variable_name == "CI_RUNNER_MODE" &&
      github_repository_dependabot_security_updates.cloudflare_home_assistant.enabled &&
      github_repository_ruleset.cloudflare_home_assistant.enforcement == "active" &&
      length(github_repository_ruleset.cloudflare_home_assistant.bypass_actors) == 0 &&
      one(github_repository_ruleset.cloudflare_home_assistant.rules).deletion &&
      one(github_repository_ruleset.cloudflare_home_assistant.rules).non_fast_forward &&
      one(one(github_repository_ruleset.cloudflare_home_assistant.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.cloudflare_home_assistant.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.cloudflare_home_assistant.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.cloudflare_home_assistant.rules).pull_request).required_review_thread_resolution &&
      one(one(github_repository_ruleset.cloudflare_home_assistant.rules).required_status_checks).strict_required_status_checks_policy &&
      { for check in one(one(github_repository_ruleset.cloudflare_home_assistant.rules).required_status_checks).required_check : check.context => check.integration_id } == { "CI gate" = 15368 }
    )
    error_message = "The public module must retain independent current-head approval, the Actions CI gate, secret protection, hosted runners, and repository-scoped bot access without bypass."
  }
}
