locals {
  repositories = {
    automations = {
      description = "Home Assistant automations: documented behavior, stable identities, and validated YAML"
      visibility  = "private"
      topics      = ["home-assistant", "home-automation", "yaml"]
    }
    scripts = {
      description = "Reusable Home Assistant scripts with documented inputs and validated YAML"
      visibility  = "private"
      topics      = ["home-assistant", "home-automation", "yaml"]
    }
    home-assistant = {
      description = "Home Assistant configuration, deployment guidance, and integration contracts"
      visibility  = "private"
      topics      = ["home-assistant", "home-automation", "k3s", "kubernetes"]
    }
    ".github" = {
      description = "HA Homelab organization profile and original visual identity"
      visibility  = "public"
      topics      = ["home-assistant", "homelab", "github-profile"]
    }
  }
}

# Terraform owns repository settings. Each repository owns its own files and CI.
resource "github_repository" "repositories" {
  for_each = local.repositories

  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility
  topics      = each.value.topics

  auto_init       = true
  has_issues      = each.value.visibility == "private"
  has_projects    = false
  has_wiki        = false
  has_discussions = false

  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  delete_branch_on_merge = true

  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"

  archive_on_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "main" {
  for_each   = github_repository.repositories
  repository = each.value.name
  branch     = "main"
}

resource "github_repository_vulnerability_alerts" "repositories" {
  for_each   = github_repository.repositories
  repository = each.value.name
}

resource "github_repository_dependabot_security_updates" "repositories" {
  for_each   = github_repository.repositories
  repository = each.value.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.repositories]
}

# GitHub Free supports branch rulesets for public repositories only. Do not
# create unenforceable protections or enable paid features for private configs.
resource "github_repository_ruleset" "profile" {
  name        = "Protect main"
  repository  = github_repository.repositories[".github"].name
  target      = "branch"
  enforcement = "active"

  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  rules {
    deletion         = true
    non_fast_forward = true
    pull_request {
      allowed_merge_methods             = ["squash"]
      required_approving_review_count   = 0
      required_review_thread_resolution = true
    }
  }
}
