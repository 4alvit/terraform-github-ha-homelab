# Reusable adapters extracted from private installations. Repository creation and
# policy are managed here; each project owns its sanitized source and release CI.
locals {
  public_adapters = {
    ha-ottplay = {
      description = "Home Assistant media players for OTTPlay devices registered with the remote control server"
      topics      = ["home-assistant", "hacs", "media-player", "ottplay", "iptv", "python"]
    }
    ha-onvif-room-direction = {
      description = "Home Assistant area estimates from read-only ONVIF camera direction, with configurable sectors and freshness checks"
      topics      = ["home-assistant", "onvif", "camera", "hacs", "python"]
    }
    ruview-home-assistant = {
      description = "RuView to Home Assistant MQTT discovery bridge with per-node observations, freshness checks and synthetic replay examples"
      topics      = ["home-assistant", "ruview", "mqtt", "presence", "python"]
    }
    ha-access-session = {
      description = "Verified Cloudflare Access sessions for external Home Assistant dashboards, with short-lived tokens and a restricted gateway"
      topics      = ["home-assistant", "cloudflare-access", "authentication", "sso", "golang", "python"]
    }
    sensing-evidence-kit = {
      description = "Record, label and compare home-sensing observations with reproducible evidence and explicit freshness and clock checks"
      topics      = ["home-assistant", "sensors", "testing", "data-validation", "python"]
    }
  }
}

resource "github_repository" "public_adapters" {
  for_each = local.public_adapters

  name                        = each.key
  description                 = each.value.description
  topics                      = each.value.topics
  visibility                  = "public"
  auto_init                   = true
  has_issues                  = true
  has_projects                = false
  has_wiki                    = false
  has_discussions             = false
  allow_merge_commit          = false
  allow_squash_merge          = true
  allow_rebase_merge          = false
  allow_auto_merge            = true
  delete_branch_on_merge      = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"
  archive_on_destroy          = true

  security_and_analysis {
    secret_scanning {
      status = "enabled"
    }
    secret_scanning_push_protection {
      status = "enabled"
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "github_branch_default" "public_adapters" {
  for_each   = github_repository.public_adapters
  repository = each.value.name
  branch     = "main"
}

resource "github_repository_vulnerability_alerts" "public_adapters" {
  for_each   = github_repository.public_adapters
  repository = each.value.name
}

resource "github_repository_dependabot_security_updates" "public_adapters" {
  for_each   = github_repository.public_adapters
  repository = each.value.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.public_adapters]
}

resource "github_workflow_repository_permissions" "public_adapters" {
  for_each                         = github_repository.public_adapters
  repository                       = each.value.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = true
}

# Same scoped reviewer as the existing public integrations; no bypass/admin role.
resource "github_repository_collaborator" "public_adapters_bot" {
  for_each   = github_repository.public_adapters
  repository = each.value.name
  username   = "californiantiramisu"
  permission = "push"
}

resource "github_actions_organization_secret_repository" "public_adapters_bot" {
  for_each      = github_repository.public_adapters
  secret_name   = "BOT_PAT"
  repository_id = each.value.repo_id
}

resource "github_repository_ruleset" "public_adapters" {
  for_each    = github_repository.public_adapters
  name        = "Protect main"
  repository  = each.value.name
  target      = "branch"
  enforcement = "active"

  # Owners may make an explicit emergency merge through an auditable PR.
  bypass_actors {
    actor_id    = local.owner_emergency_merge_actor.actor_id
    actor_type  = local.owner_emergency_merge_actor.actor_type
    bypass_mode = local.owner_emergency_merge_actor.bypass_mode
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
      required_approving_review_count   = 1
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        context        = "CI gate"
        integration_id = 15368
      }
    }
  }
  depends_on = [github_branch_default.public_adapters]
}

resource "github_repository_ruleset" "public_adapters_tags" {
  for_each    = github_repository.public_adapters
  name        = "Release standard - immutable version tags"
  repository  = each.value.name
  target      = "tag"
  enforcement = "active"
  conditions {
    ref_name {
      include = ["refs/tags/v*"]
      exclude = []
    }
  }
  rules {
    deletion         = true
    update           = true
    non_fast_forward = true
  }
}

resource "github_repository_environment" "public_adapters_release" {
  for_each            = github_repository.public_adapters
  repository          = each.value.name
  environment         = "release"
  prevent_self_review = false
  can_admins_bypass   = true
  reviewers {
    users = [272257197] # Existing organization maintainer; same policy as LG capture.
  }
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "public_adapters_release" {
  for_each       = github_repository.public_adapters
  repository     = each.value.name
  environment    = github_repository_environment.public_adapters_release[each.key].environment
  branch_pattern = "main"
}

resource "github_actions_variable" "public_adapters_release" {
  for_each      = github_repository.public_adapters
  repository    = each.value.name
  variable_name = "RELEASE_CHANNELS_ENABLED"
  value         = "true"
  depends_on = [
    github_repository_ruleset.public_adapters,
    github_repository_ruleset.public_adapters_tags,
    github_repository_environment_deployment_policy.public_adapters_release,
  ]
}
