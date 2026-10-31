mock_provider "github" {
  override_during = plan
  mock_data "github_repository" {
    defaults = {
      visibility = "public"
      archived   = false
    }
  }
}

run "review_bot_access_is_six_singleton_memberships_only" {
  command = plan
  override_data {
    target = data.github_repository.public_release_review_targets["assist-scenario-lab"]
    values = { repo_id = 101, visibility = "public", archived = false }
  }
  override_data {
    target = data.github_repository.public_release_review_targets["ha-entity-migrations"]
    values = { repo_id = 102, visibility = "public", archived = false }
  }
  override_data {
    target = data.github_repository.public_release_review_targets["ha-meter-contracts"]
    values = { repo_id = 103, visibility = "public", archived = false }
  }
  override_data {
    target = data.github_repository.public_release_review_targets["ha-scenario-tests"]
    values = { repo_id = 104, visibility = "public", archived = false }
  }
  override_data {
    target = data.github_repository.public_release_review_targets["home-studio"]
    values = { repo_id = 105, visibility = "public", archived = false }
  }
  override_data {
    target = data.github_repository.public_release_review_targets["zac93-esp32"]
    values = { repo_id = 106, visibility = "public", archived = false }
  }
  assert {
    condition = (
      toset(keys(github_actions_organization_secret_repository.public_review_bot_access)) == toset([
        "assist-scenario-lab",
        "ha-entity-migrations",
        "ha-meter-contracts",
        "ha-scenario-tests",
        "home-studio",
        "zac93-esp32",
      ]) &&
      alltrue([
        for name, membership in github_actions_organization_secret_repository.public_review_bot_access :
        membership.secret_name == "BOT_PAT" &&
        membership.repository_id == data.github_repository.public_release_review_targets[name].repo_id &&
        data.github_repository.public_release_review_targets[name].full_name == "ha-homelab/${name}"
      ]) &&
      toset([for membership in github_actions_organization_secret_repository.public_review_bot_access : membership.repository_id]) == toset([101, 102, 103, 104, 105, 106]) &&
      !contains(keys(github_actions_organization_secret_repository.public_review_bot_access), ".github") &&
      !contains(keys(github_actions_organization_secret_repository.public_review_bot_access), "ha-echo-dot")
    )
    error_message = "Only the six missing repositories may join the existing BOT_PAT allowlist; existing profile and first-wave memberships must remain outside this resource."
  }
}

run "private_repository_cannot_receive_review_credential" {
  command = plan
  override_data {
    target = data.github_repository.public_release_review_targets["zac93-esp32"]
    values = {
      visibility = "private"
      archived   = false
    }
  }
  expect_failures = [
    github_repository_collaborator.public_release_reviewers["zac93-esp32"],
    github_actions_organization_secret_repository.public_review_bot_access["zac93-esp32"],
  ]
}

run "archived_repository_cannot_receive_review_credential" {
  command = plan
  override_data {
    target = data.github_repository.public_release_review_targets["zac93-esp32"]
    values = {
      visibility = "public"
      archived   = true
    }
  }
  expect_failures = [
    github_repository_collaborator.public_release_reviewers["zac93-esp32"],
    github_actions_organization_secret_repository.public_review_bot_access["zac93-esp32"],
  ]
}
