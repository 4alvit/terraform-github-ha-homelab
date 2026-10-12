mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "existing_public_rules_require_one_current_review" {
  command = plan
  variables {
    public_security_enforcement_repositories = ["ha-desloc", "ha-desloc-card", "ha-echo-dot", "ha-echo-show-5", "slzb-06-recovery", "rf-airbridge"]
  }
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
        one(one(policy.rules).pull_request).required_approving_review_count == 1 &&
        one(one(policy.rules).pull_request).dismiss_stale_reviews_on_push &&
        one(one(policy.rules).pull_request).require_last_push_approval &&
        one(one(policy.rules).pull_request).required_review_thread_resolution
      )
    ])
    error_message = "Every actual public software ruleset must require one current review without bypass."
  }
}

run "private_repository_preserves_existing_policy" {
  variables {
    public_security_enforcement_repositories = ["ha-desloc"]
  }
  command         = plan
  expect_failures = [github_repository_collaborator.desloc_coderabbit["ha-desloc"]]
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
  variables {
    public_security_enforcement_repositories = ["ha-desloc"]
  }
  command         = plan
  expect_failures = [github_repository_collaborator.desloc_coderabbit["ha-desloc"]]
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

run "coderabbit_write_access_is_limited_to_desloc" {
  command = plan
  assert {
    condition = (
      toset(keys(github_repository_collaborator.desloc_coderabbit)) == toset(["ha-desloc", "ha-desloc-card"]) &&
      alltrue([
        for name, collaborator in github_repository_collaborator.desloc_coderabbit :
        collaborator.repository == name &&
        collaborator.username == "californiantiramisu" &&
        collaborator.permission == "push"
      ])
    )
    error_message = "Only the two DESLOC repositories may grant the autofix account Write access."
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

run "new_public_button_repository_has_protections_without_live_lookup" {
  command = plan
  assert {
    condition = (
      github_repository.repositories["zigbee-direct-button"].visibility == "public" &&
      one(one(github_repository.repositories["zigbee-direct-button"].security_and_analysis).secret_scanning).status == "enabled" &&
      one(one(github_repository.repositories["zigbee-direct-button"].security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
      length(github_repository_ruleset.zigbee_direct_button.bypass_actors) == 0 &&
      one(one(github_repository_ruleset.zigbee_direct_button.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.zigbee_direct_button.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.zigbee_direct_button.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.zigbee_direct_button.rules).pull_request).required_review_thread_resolution
    )
    error_message = "The new public button repository must bootstrap with secret protection and the same review policy."
  }
}

run "new_public_conversion_repository_has_protections_without_live_lookup" {
  command = plan
  assert {
    condition = (
      github_repository.repositories["ha-tuya-esphome"].visibility == "public" &&
      one(one(github_repository.repositories["ha-tuya-esphome"].security_and_analysis).secret_scanning).status == "enabled" &&
      one(one(github_repository.repositories["ha-tuya-esphome"].security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
      toset(one(one(github_repository_ruleset.tuya_esphome.conditions).ref_name).include) == toset(["~DEFAULT_BRANCH"]) &&
      length(one(one(github_repository_ruleset.tuya_esphome.conditions).ref_name).exclude) == 0 &&
      length(github_repository_ruleset.tuya_esphome.bypass_actors) == 0 &&
      one(one(github_repository_ruleset.tuya_esphome.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.tuya_esphome.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.tuya_esphome.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.tuya_esphome.rules).pull_request).required_review_thread_resolution
    )
    error_message = "The new conversion repository must require secret protection and one current review without bypass."
  }
}

run "home_assistant_predecessor_keeps_private_identity" {
  command = plan
  assert {
    condition = (
      github_repository.repositories["home-assistant"].name == "home-assistant-private" &&
      github_repository.repositories["home-assistant"].visibility == "private" &&
      length(github_repository.repositories["home-assistant"].security_and_analysis) == 0 &&
      github_repository.repositories["automations"].visibility == "private" &&
      github_repository.repositories["scripts"].visibility == "private"
    )
    error_message = "The old repository and component histories must remain private at their existing resource addresses."
  }
}

run "public_home_assistant_has_fresh_history_and_least_privilege_ci" {
  command = plan
  assert {
    condition = (
      github_repository.home_assistant_public.name == "home-assistant" &&
      github_repository.home_assistant_public.visibility == "public" &&
      !github_repository.home_assistant_public.auto_init &&
      one(one(github_repository.home_assistant_public.security_and_analysis).secret_scanning).status == "enabled" &&
      one(one(github_repository.home_assistant_public.security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
      github_workflow_repository_permissions.home_assistant_public.default_workflow_permissions == "read" &&
      github_workflow_repository_permissions.home_assistant_public.can_approve_pull_request_reviews
    )
    error_message = "The new repository must start empty, protect secrets, retain read-only token defaults, and allow explicitly scoped PR approval jobs."
  }
}

run "public_home_assistant_protects_reviewed_main" {
  command = plan
  assert {
    condition = (
      github_branch_default.home_assistant_public.branch == "main" &&
      github_repository_ruleset.home_assistant_public.enforcement == "active" &&
      length(github_repository_ruleset.home_assistant_public.bypass_actors) == 0 &&
      one(github_repository_ruleset.home_assistant_public.rules).deletion &&
      one(github_repository_ruleset.home_assistant_public.rules).non_fast_forward &&
      one(one(github_repository_ruleset.home_assistant_public.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.home_assistant_public.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.home_assistant_public.rules).pull_request).require_last_push_approval &&
      toset([for check in one(one(github_repository_ruleset.home_assistant_public.rules).required_status_checks).required_check : check.context]) == toset(["validate", "maintenance-runtime"])
    )
    error_message = "Public Home Assistant main must require current reviews and both CI checks, without a bypass."
  }
}

run "unactivated_public_reviews_preserve_existing_bypasses" {
  command = plan
  assert {
    condition = alltrue([
      for policy in [
        github_repository_ruleset.desloc,
        github_repository_ruleset.desloc_card,
        github_repository_ruleset.echo_dot,
        github_repository_ruleset.echo_show_5,
        github_repository_ruleset.slzb_06_recovery,
        github_repository_ruleset.rf_airbridge
        ] : (
        length(policy.bypass_actors) == 1 &&
        one(one(policy.rules).pull_request).required_approving_review_count == 0 &&
        !one(one(policy.rules).pull_request).require_last_push_approval &&
        !one(one(policy.rules).pull_request).dismiss_stale_reviews_on_push
      )
    ])
    error_message = "Existing reviews and bypasses must remain until explicitly activated."
  }
}

run "existing_ci_and_auto_merge_settings_are_preserved" {
  command = plan
  assert {
    condition = (
      github_repository.repositories["zigbee-direct-button"].allow_auto_merge &&
      github_repository.repositories["ha-tuya-esphome"].allow_auto_merge &&
      !github_repository.repositories[".github"].allow_auto_merge &&
      toset([for check in one(one(github_repository_ruleset.zigbee_direct_button.rules).required_status_checks).required_check : check.context]) == toset(["CI gate", "test"]) &&
      toset([for check in one(one(github_repository_ruleset.tuya_esphome.rules).required_status_checks).required_check : check.context]) == toset(["check"]) &&
      toset([for check in one(one(github_repository_ruleset.echo_show_5.rules).required_status_checks).required_check : check.context]) == toset(["CI gate"])
    )
    error_message = "The existing automatic merge and mandatory CI settings must not regress."
  }
}
