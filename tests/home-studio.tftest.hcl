mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      name       = "home-studio"
      visibility = "public"
      archived   = false
    }
  }
}

run "home_studio_requires_its_exact_ci_gate_with_owner_exception" {
  command = plan

  assert {
    condition = (
      data.github_repository.home_studio.full_name == "ha-homelab/home-studio" &&
      github_repository_ruleset.home_studio_ci.repository == "home-studio" &&
      github_repository_ruleset.home_studio_ci.target == "branch" &&
      github_repository_ruleset.home_studio_ci.enforcement == "active" &&
      (
        length([for actor in github_repository_ruleset.home_studio_ci.bypass_actors : actor if actor.actor_type == local.owner_emergency_merge_actor.actor_type]) == 1 &&
        alltrue([
          for actor in github_repository_ruleset.home_studio_ci.bypass_actors :
          coalesce(actor.actor_id, 0) == coalesce(local.owner_emergency_merge_actor.actor_id, 0) && actor.bypass_mode == "pull_request"
          if actor.actor_type == local.owner_emergency_merge_actor.actor_type
        ]) &&
        length([for actor in github_repository_ruleset.home_studio_ci.bypass_actors : actor if actor.actor_type != local.owner_emergency_merge_actor.actor_type]) == 0
      ) &&
      one(one(github_repository_ruleset.home_studio_ci.conditions).ref_name).include == tolist(["~DEFAULT_BRANCH"]) &&
      length(one(one(github_repository_ruleset.home_studio_ci.conditions).ref_name).exclude) == 0 &&
      length(one(github_repository_ruleset.home_studio_ci.rules).pull_request) == 1 &&
      one(one(github_repository_ruleset.home_studio_ci.rules).pull_request).required_approving_review_count == 0 &&
      one(one(github_repository_ruleset.home_studio_ci.rules).required_status_checks).strict_required_status_checks_policy &&
      length(one(one(github_repository_ruleset.home_studio_ci.rules).required_status_checks).required_check) == 1 &&
      one(one(one(github_repository_ruleset.home_studio_ci.rules).required_status_checks).required_check).context == "CI gate" &&
      one(one(one(github_repository_ruleset.home_studio_ci.rules).required_status_checks).required_check).integration_id == 15368
    )
    error_message = "Home Studio must require its GitHub Actions CI gate and a pull request on the default branch, with only the documented owner exception or additional review requirements."
  }
}

run "private_home_studio_cannot_enable_public_enforcement" {
  command = plan
  override_data {
    target = data.github_repository.home_studio
    values = {
      name       = "home-studio"
      visibility = "private"
      archived   = false
    }
  }
  expect_failures = [data.github_repository.home_studio]
}

run "archived_home_studio_cannot_enable_public_enforcement" {
  command = plan
  override_data {
    target = data.github_repository.home_studio
    values = {
      name       = "home-studio"
      visibility = "public"
      archived   = true
    }
  }
  expect_failures = [data.github_repository.home_studio]
}
