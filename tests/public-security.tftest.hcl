mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "existing_public_rules_require_two_current_reviews" {
  command = plan
  assert {
    condition = length(local.active_public_software_repositories) == 6 && alltrue([
      for policy in [
        github_repository_ruleset.desloc,
        github_repository_ruleset.desloc_card,
        github_repository_ruleset.echo_dot,
        github_repository_ruleset.echo_show_5,
        github_repository_ruleset.slzb_06_recovery,
        github_repository_ruleset.rf_airbridge
        ] : (
        length(policy.bypass_actors) == 0 &&
        one(one(policy.rules).pull_request).required_approving_review_count == 2 &&
        one(one(policy.rules).pull_request).dismiss_stale_reviews_on_push &&
        one(one(policy.rules).pull_request).require_last_push_approval &&
        one(one(policy.rules).pull_request).required_review_thread_resolution
      )
    ])
    error_message = "Every actual public software ruleset must require two current reviews without bypass."
  }
}

run "private_repository_preserves_existing_policy" {
  command = plan
  override_data {
    target = data.github_repository.public_software["ha-desloc"]
    values = {
      visibility = "private"
      archived   = false
    }
  }
  assert {
    condition = (
      !contains(local.active_public_software_repositories, "ha-desloc") &&
      length(github_repository_ruleset.desloc.bypass_actors) == 1 &&
      one(one(github_repository_ruleset.desloc.rules).pull_request).required_approving_review_count == 0 &&
      !one(one(github_repository_ruleset.desloc.rules).pull_request).require_last_push_approval &&
      !one(one(github_repository_ruleset.desloc.rules).pull_request).dismiss_stale_reviews_on_push &&
      length(github_repository.repositories["ha-desloc"].security_and_analysis) == 0
    )
    error_message = "An excluded repository must retain its existing policy and receive no public security settings."
  }
}

run "archived_repository_preserves_existing_policy" {
  command = plan
  override_data {
    target = data.github_repository.public_software["ha-desloc"]
    values = {
      visibility = "public"
      archived   = true
    }
  }
  assert {
    condition = (
      !contains(local.active_public_software_repositories, "ha-desloc") &&
      length(github_repository_ruleset.desloc.bypass_actors) == 1 &&
      one(one(github_repository_ruleset.desloc.rules).pull_request).required_approving_review_count == 0 &&
      !one(one(github_repository_ruleset.desloc.rules).pull_request).require_last_push_approval &&
      !one(one(github_repository_ruleset.desloc.rules).pull_request).dismiss_stale_reviews_on_push &&
      length(github_repository.repositories["ha-desloc"].security_and_analysis) == 0
    )
    error_message = "An excluded repository must retain its existing policy and receive no public security settings."
  }
}

run "profile_and_private_repository_settings_are_unchanged" {
  command = plan
  assert {
    condition = (
      length(github_repository_ruleset.profile.bypass_actors) == 1 &&
      one(one(github_repository_ruleset.profile.rules).pull_request).required_approving_review_count == 0 &&
      length(github_repository.repositories[".github"].security_and_analysis) == 0 &&
      length(github_repository.repositories["automations"].security_and_analysis) == 0
    )
    error_message = "The profile and private repository must remain outside the public software rollout."
  }
}
