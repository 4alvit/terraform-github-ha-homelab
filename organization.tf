# Adopt the existing organization; billing and access defaults remain unchanged.
# GitHub's avatar upload is outside the Terraform provider's supported settings.
resource "github_organization_settings" "organization" {
  billing_email = var.billing_email
  name          = "HA Homelab"
  description   = "A thoughtfully automated home, managed as code."

  # Preserve the existing access, project, and security defaults. Repository
  # security features are enabled explicitly in main.tf without a paid upgrade.
  default_repository_permission                                = "read"
  has_organization_projects                                    = true
  has_repository_projects                                      = true
  members_can_create_repositories                              = true
  members_can_create_public_repositories                       = true
  members_can_create_private_repositories                      = true
  members_can_create_internal_repositories                     = false
  members_can_create_pages                                     = true
  members_can_create_public_pages                              = true
  members_can_create_private_pages                             = true
  members_can_fork_private_repositories                        = false
  web_commit_signoff_required                                  = false
  advanced_security_enabled_for_new_repositories               = false
  dependabot_alerts_enabled_for_new_repositories               = false
  dependabot_security_updates_enabled_for_new_repositories     = false
  dependency_graph_enabled_for_new_repositories                = false
  secret_scanning_enabled_for_new_repositories                 = false
  secret_scanning_push_protection_enabled_for_new_repositories = false

  lifecycle {
    prevent_destroy = true
  }
}

import {
  to = github_organization_settings.organization
  id = "ha-homelab"
}
