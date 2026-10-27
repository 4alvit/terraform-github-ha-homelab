mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "battery_card_bootstraps_public_protection_without_additional_access" {
  command = plan

  assert {
    condition = (
      github_repository.repositories["ha-jbd-bms-card"].visibility == "public" &&
      one(one(github_repository.repositories["ha-jbd-bms-card"].security_and_analysis).secret_scanning).status == "enabled" &&
      one(one(github_repository.repositories["ha-jbd-bms-card"].security_and_analysis).secret_scanning_push_protection).status == "enabled" &&
      github_workflow_repository_permissions.jbd_bms_card.default_workflow_permissions == "read" &&
      !github_workflow_repository_permissions.jbd_bms_card.can_approve_pull_request_reviews
    )
    error_message = "The new public card must enable secret protection at creation without granting write/approval permissions to workflow tokens."
  }

  assert {
    condition = (
      github_repository_ruleset.jbd_bms_card.enforcement == "active" &&
      (
        length([for actor in github_repository_ruleset.jbd_bms_card.bypass_actors : actor if actor.actor_type == local.owner_emergency_merge_actor.actor_type]) == 1 &&
        alltrue([
          for actor in github_repository_ruleset.jbd_bms_card.bypass_actors :
          coalesce(actor.actor_id, 0) == coalesce(local.owner_emergency_merge_actor.actor_id, 0) && actor.bypass_mode == "pull_request"
          if actor.actor_type == local.owner_emergency_merge_actor.actor_type
        ]) &&
        length([for actor in github_repository_ruleset.jbd_bms_card.bypass_actors : actor if actor.actor_type != local.owner_emergency_merge_actor.actor_type]) == 0
      ) &&
      one(github_repository_ruleset.jbd_bms_card.rules).deletion &&
      one(github_repository_ruleset.jbd_bms_card.rules).non_fast_forward &&
      one(one(github_repository_ruleset.jbd_bms_card.rules).pull_request).required_approving_review_count == 1 &&
      one(one(github_repository_ruleset.jbd_bms_card.rules).pull_request).dismiss_stale_reviews_on_push &&
      one(one(github_repository_ruleset.jbd_bms_card.rules).pull_request).require_last_push_approval &&
      one(one(github_repository_ruleset.jbd_bms_card.rules).pull_request).required_review_thread_resolution &&
      one(one(github_repository_ruleset.jbd_bms_card.rules).required_status_checks).strict_required_status_checks_policy &&
      one(one(one(github_repository_ruleset.jbd_bms_card.rules).required_status_checks).required_check).context == "CI gate" &&
      one(one(one(github_repository_ruleset.jbd_bms_card.rules).required_status_checks).required_check).integration_id == 15368
    )
    error_message = "Battery-card changes must require an independent current approval and app-bound CI without weakening history protection or allowing bypass."
  }
}
