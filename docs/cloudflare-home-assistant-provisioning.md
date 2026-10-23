# Provision the public Cloudflare/Home Assistant module

`cloudflare-home-assistant.tf` owns only GitHub metadata for
`ha-homelab/terraform-cloudflare-home-assistant`. It does not import an existing
Cloudflare deployment, move its state, publish deployment inputs or grant access
to Cloudflare. Public source is reviewed and published separately.

## Bootstrap in the canonical HCP workspace

1. Validate source and run the mocked policy tests.
2. Plan only the nine creation resources below. Review the saved remote plan:
   every non-no-op action must be a creation at one of these addresses. Apply that
   reviewed plan without including unrelated workspace changes.
3. Publish the separately reviewed, sanitized initial source to `main` in the new
   empty repository. The initial source must define the `CI gate` check.
4. Plan and apply `github_branch_default.cloudflare_home_assistant` and
   `github_repository_ruleset.cloudflare_home_assistant`. Their dependencies may
   appear as no-ops; reject unexpected updates. The ruleset allows only squash PR
   merges, one current independent approval, resolved review threads and successful
   up-to-date `CI gate` from GitHub Actions. It has no bypass actors.
5. Reconcile only this new ruleset's
   `require_extra_approval_for_unattributed_changes` flag to `false`, preserving
   every other field and saving a private before/after receipt. The pinned provider
   cannot serialize this flag; see [the existing review-policy procedure](public-security.md#extra-copilot-approval-after-terraform).
   Do not apply unrelated organization-wide reconciliation changes.
6. Accept only the scoped review-bot invitation with the existing metadata-only
   `accept-adapter-reviewer.yml` workflow after this change is on `main`. Verify
   effective Write permission. An invitation alone is not an accepted role.
7. Verify public visibility, protections, Actions defaults, dependency alerts and
   this repository's membership in the existing `BOT_PAT` allowlist. Finish with
   a fresh scoped plan showing no changes. A scoped no-op is not evidence that
   unrelated full-workspace drift has been reconciled.

The first stage contains these addresses:

```text
github_repository.cloudflare_home_assistant
github_workflow_repository_permissions.cloudflare_home_assistant
github_repository_collaborator.cloudflare_home_assistant_bot
github_actions_organization_secret_repository.cloudflare_home_assistant_bot
github_issue_label.cloudflare_home_assistant_automerge
github_issue_label.cloudflare_home_assistant_autoapprove
github_actions_variable.cloudflare_home_assistant_hosted
github_repository_vulnerability_alerts.cloudflare_home_assistant
github_repository_dependabot_security_updates.cloudflare_home_assistant
```

Terraform manages the existing organization secret's single allowlist membership,
never its value or the allowlist for other repositories. The bot has Write access,
not administrator access. `GITHUB_TOKEN` is read-only by default; Actions may
submit approvals when a reviewed workflow explicitly requests that permission.
Public CI starts on GitHub-hosted runners. Ordinary contributors supply only their
own Cloudflare deployment inputs; this governance configuration is not a required
part of using the public module.

## Recovery

Keep remote state and repository identity. Both accidental destruction and silent
replacement are blocked by `prevent_destroy`; `archive_on_destroy` is an additional
safeguard. If creation succeeded but an apply was interrupted, refresh the canonical
state and import only the missing resource identities before retrying. Do not
create a second repository, overwrite a secret or change other repositories to
repair this bootstrap.
