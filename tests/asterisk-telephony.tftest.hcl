mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "asterisk_requires_current_review_and_real_app_bound_checks" {
  command = plan
  assert {
    condition = (
      github_repository_ruleset.asterisk_telephony.enforcement == "active" &&
      github_repository_ruleset.asterisk_telephony.repository == "asterisk-telephony" &&
      github_repository_ruleset.asterisk_telephony.target == "branch" &&
      toset(one(one(github_repository_ruleset.asterisk_telephony.conditions).ref_name).include) == toset(["~DEFAULT_BRANCH"]) &&
      length(one(one(github_repository_ruleset.asterisk_telephony.conditions).ref_name).exclude) == 0 &&
      one(github_repository_ruleset.asterisk_telephony.rules).deletion &&
      one(github_repository_ruleset.asterisk_telephony.rules).non_fast_forward &&
      one(one(github_repository_ruleset.asterisk_telephony.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.asterisk_telephony.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.asterisk_telephony.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.asterisk_telephony.rules).pull_request).required_review_thread_resolution &&
      one(one(github_repository_ruleset.asterisk_telephony.rules).required_status_checks).strict_required_status_checks_policy &&
      { for check in one(one(github_repository_ruleset.asterisk_telephony.rules).required_status_checks).required_check : check.context => check.integration_id } == {
        "test"                                                        = 15368
        "home-assistant-runtime (requirements-runtime.txt)"           = 15368
        "home-assistant-runtime (requirements-runtime-2026.10.0.txt)" = 15368
        "CodeQL"                                                      = 57789
      }
    )
    error_message = "Asterisk must require one fresh review and all four real app-bound checks on the default branch, with protected history."
  }
}

run "asterisk_reviewer_can_approve_but_cannot_bypass" {
  command = plan
  assert {
    condition = (
      length(github_repository_ruleset.asterisk_telephony.bypass_actors) == 1 &&
      one(github_repository_ruleset.asterisk_telephony.bypass_actors).actor_type == "OrganizationAdmin" &&
      one(github_repository_ruleset.asterisk_telephony.bypass_actors).bypass_mode == "always" &&
      github_repository_collaborator.public_release_reviewers["asterisk-telephony"].repository == "asterisk-telephony" &&
      github_repository_collaborator.public_release_reviewers["asterisk-telephony"].username == "californiantiramisu" &&
      github_repository_collaborator.public_release_reviewers["asterisk-telephony"].permission == "push" &&
      github_workflow_repository_permissions.asterisk_telephony.default_workflow_permissions == "read" &&
      github_workflow_repository_permissions.asterisk_telephony.can_approve_pull_request_reviews
    )
    error_message = "Only organization owners may bypass. The existing bot gets scoped Write and independent Actions reviews are allowed while default workflow permissions remain read-only."
  }
}

run "asterisk_private_review_grant_is_rejected" {
  command = plan
  plan_options {
    target = [github_repository_collaborator.public_release_reviewers["asterisk-telephony"]]
  }
  override_data {
    target = data.github_repository.public_release_review_targets["asterisk-telephony"]
    values = {
      visibility = "private"
      archived   = false
    }
  }
  expect_failures = [github_repository_collaborator.public_release_reviewers["asterisk-telephony"]]
}
