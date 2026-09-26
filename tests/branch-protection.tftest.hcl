mock_provider "github" {}

override_resource {
  target = github_organization_settings.organization
  values = { id = "mock-existing-organization" }
}

variables {
  github_token  = "mock-provider-no-credential"
  billing_email = "terraform-test@example.invalid"
}

run "free_plan_reports_blocked_private_protection" {
  command = plan

  override_data {
    target = data.github_organization.current
    values = { plan = "free" }
  }

  assert {
    condition = (
      length(github_repository_ruleset.private_main) == 0 &&
      length(output.branch_protection.pending_private_repositories) == 4 &&
      github_repository_ruleset.profile.enforcement == "active" &&
      alltrue([for repository in github_repository.repositories : !repository.allow_auto_merge])
    )
    error_message = "Free must preserve public protection and report all four private repositories as blocked, without attempting unsupported API writes."
  }
}

run "team_plan_enforces_private_pull_requests_and_checks" {
  command = plan

  override_data {
    target = data.github_organization.current
    values = { plan = "team" }
  }

  assert {
    condition = (
      toset(keys(github_repository_ruleset.private_main)) == toset(["home-assistant", "automations", "scripts", "home-floorplan-3d"]) &&
      length(output.branch_protection.pending_private_repositories) == 0 &&
      alltrue([
        for name, rule in github_repository_ruleset.private_main :
        rule.enforcement == "active" &&
        rule.rules[0].deletion && rule.rules[0].non_fast_forward &&
        length(rule.bypass_actors) == 0 &&
        rule.rules[0].pull_request[0].required_review_thread_resolution &&
        rule.rules[0].pull_request[0].required_approving_review_count == 0 &&
        rule.rules[0].required_status_checks[0].strict_required_status_checks_policy &&
        github_repository.repositories[name].allow_auto_merge &&
        github_repository.repositories[name].visibility == "private"
      ])
    )
    error_message = "Team must protect all private default branches without administrator bypasses or visibility changes, and enable CI-gated auto-merge."
  }

  assert {
    condition = (
      toset([for check in github_repository_ruleset.private_main["home-assistant"].rules[0].required_status_checks[0].required_check : check.context]) == toset(["validate", "maintenance-runtime"]) &&
      toset([for check in github_repository_ruleset.private_main["automations"].rules[0].required_status_checks[0].required_check : check.context]) == toset(["Validate automation contracts"]) &&
      toset([for check in github_repository_ruleset.private_main["scripts"].rules[0].required_status_checks[0].required_check : check.context]) == toset(["Validate YAML and behavior contracts"]) &&
      toset([for check in github_repository_ruleset.private_main["home-floorplan-3d"].rules[0].required_status_checks[0].required_check : check.context]) == toset(["validate", "home-assistant"]) &&
      alltrue(flatten([for rule in github_repository_ruleset.private_main : [for check in rule.rules[0].required_status_checks[0].required_check : check.integration_id == 15368]]))
    )
    error_message = "Required check names must match each repository's real CI and be bound to GitHub Actions."
  }
}

run "enterprise_plan_supports_private_rulesets" {
  command = plan

  override_data {
    target = data.github_organization.current
    values = { plan = "enterprise" }
  }

  assert {
    condition     = length(github_repository_ruleset.private_main) == 4
    error_message = "Enterprise must enable the same four private rulesets."
  }
}

run "unknown_plan_fails_instead_of_claiming_protection" {
  command = plan

  override_data {
    target = data.github_organization.current
    values = { plan = "" }
  }

  expect_failures = [data.github_organization.current]
}
