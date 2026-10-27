mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "scoped_reviewer_has_write_without_administration" {
  command = plan
  plan_options {
    target = [github_repository_collaborator.public_release_reviewers]
  }
  assert {
    condition = (
      toset(keys(github_repository_collaborator.public_release_reviewers)) == toset([".github", "assist-scenario-lab", "ha-echo-dot", "ha-echo-show-5", "ha-entity-migrations", "ha-jbd-bms-card", "ha-meter-contracts", "ha-scenario-tests", "home-assistant", "home-studio", "k3s-self-healing", "rf-airbridge", "slzb-06-recovery", "zac93-esp32"]) &&
      alltrue([for name, reviewer in github_repository_collaborator.public_release_reviewers :
        reviewer.repository == name &&
        reviewer.username == "californiantiramisu" &&
        reviewer.permission == "push"
      ])
    )
    error_message = "Only the existing bot receives repository-scoped Write access."
  }
}

run "private_target_is_rejected" {
  command = plan
  plan_options {
    target = [github_repository_collaborator.public_release_reviewers]
  }
  override_data {
    target = data.github_repository.public_release_review_targets["home-assistant"]
    values = {
      visibility = "private"
      archived   = false
    }
  }
  expect_failures = [github_repository_collaborator.public_release_reviewers["home-assistant"]]
}

run "archived_target_is_rejected" {
  command = plan
  plan_options {
    target = [github_repository_collaborator.public_release_reviewers]
  }
  override_data {
    target = data.github_repository.public_release_review_targets["home-assistant"]
    values = {
      visibility = "public"
      archived   = true
    }
  }
  expect_failures = [github_repository_collaborator.public_release_reviewers["home-assistant"]]
}
