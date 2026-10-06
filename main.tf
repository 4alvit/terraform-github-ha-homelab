locals {
  repositories = {
    slzb-06-recovery = {
      description = "SMLIGHT SLZB-06 backup, core and Zigbee coordinator upgrades, tested legacy Ethernet recovery tools, and troubleshooting"
      visibility  = "public"
      has_issues  = true
      topics      = ["smlight", "slzb-06", "zigbee", "home-assistant", "firmware", "recovery"]
    }
    ha-echo-show-5 = {
      description = "Reuse Echo Show 5 Gen2 with Android and Home Assistant: amonet and TWRP conversion, verified backups, LineageOS installation and Companion setup"
      visibility  = "public"
      has_issues  = true
      topics      = ["amazon-echo", "android", "echo-show-5", "home-assistant", "lineageos", "twrp"]
    }
    ha-echo-dot = {
      description = "Reuse Echo Dot 2 with EchoLocal and Home Assistant: conversion guide, Russian wake-word training, exact-runtime evaluation and HA setup"
      visibility  = "public"
      has_issues  = true
      topics      = ["amazon-echo", "echo-dot", "echolocal", "home-assistant", "microwakeword", "voice-assistant"]
    }
    ha-desloc = {
      description = "Unofficial DESLOC C100 Plus cloud integration for Home Assistant: lock control, state, battery and Wi-Fi signal"
      visibility  = "public"
      has_issues  = true
      topics      = ["desloc", "hacs", "home-assistant", "home-assistant-custom-component", "smart-lock", "python"]
    }
    ha-desloc-card = {
      description = "Home Assistant Lovelace card for DESLOC locks: state, battery, Wi-Fi signal and confirmed unlock controls"
      visibility  = "public"
      has_issues  = true
      topics      = ["desloc", "hacs", "home-assistant", "lovelace-custom-card", "smart-lock", "javascript"]
    }
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
    home-floorplan-3d = {
      description = "Private residential floor plan, reproducible 3D models, and Home Assistant device placement"
      visibility  = "private"
      topics      = ["home-assistant", "floorplan", "gltf", "usdz", "3d"]
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
  has_issues      = try(each.value.has_issues, each.value.visibility == "private")
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

# Protect the public profile only. Private repositories intentionally rely on
# the owners' PR/CI workflow; a plan upgrade must not enable rules automatically.
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

# Public integration source follows the same PR and history protection pattern.
resource "github_repository_ruleset" "desloc" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-desloc"].name
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

# The dashboard card is independently installable through HACS.
resource "github_repository_ruleset" "desloc_card" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-desloc-card"].name
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

# Public EchoLocal guides and training tools use the same history protection.
resource "github_repository_ruleset" "echo_dot" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-echo-dot"].name
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

# Public Show 5 conversion guides and tools use the same history protection.
resource "github_repository_ruleset" "echo_show_5" {
  name        = "Protect main"
  repository  = github_repository.repositories["ha-echo-show-5"].name
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

# Public recovery documentation and tools follow the same PR/history protection.
resource "github_repository_ruleset" "slzb_06_recovery" {
  name        = "Protect main"
  repository  = github_repository.repositories["slzb-06-recovery"].name
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
