# A reusable, public Home Assistant/Asterisk companion. No household configuration,
# SIP credentials, firmware, collaborator grants or runner infrastructure lives here.
resource "github_repository" "asterisk_telephony" {
  name                        = "asterisk-telephony"
  description                 = "Home Assistant integration for Asterisk: verified installer, phone dashboards, call actions, Assist and deployment documentation"
  topics                      = ["home-assistant", "asterisk", "telephony", "sip", "k3s", "python"]
  visibility                  = "public"
  auto_init                   = true
  has_issues                  = true
  has_projects                = false
  has_wiki                    = false
  has_discussions             = false
  allow_merge_commit          = false
  allow_squash_merge          = true
  allow_rebase_merge          = false
  allow_auto_merge            = false
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

resource "github_branch_default" "asterisk_telephony" {
  repository = github_repository.asterisk_telephony.name
  branch     = "main"
}

resource "github_repository_vulnerability_alerts" "asterisk_telephony" {
  repository = github_repository.asterisk_telephony.name
}

resource "github_repository_dependabot_security_updates" "asterisk_telephony" {
  repository = github_repository.asterisk_telephony.id
  enabled    = true
  depends_on = [github_repository_vulnerability_alerts.asterisk_telephony]
}

resource "github_workflow_repository_permissions" "asterisk_telephony" {
  repository                       = github_repository.asterisk_telephony.name
  default_workflow_permissions     = "read"
  can_approve_pull_request_reviews = false
}

output "asterisk_telephony_repository" {
  description = "Public reusable Asterisk/Home Assistant companion repository."
  value = {
    html_url   = github_repository.asterisk_telephony.html_url
    ssh_url    = github_repository.asterisk_telephony.ssh_clone_url
    visibility = github_repository.asterisk_telephony.visibility
  }
}
