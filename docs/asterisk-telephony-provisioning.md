# Asterisk telephony companion provisioning

Terraform in the existing HCP workspace owns the new public
`ha-homelab/asterisk-telephony` repository and only its repository settings.
This is not a fork or visibility change of household configuration. Source is
published separately after its own public-data review. GitHub-hosted standard
Linux runners execute public source validation; no paid/larger runner, private
runner, bot collaborator, organization secret allowlist, or billing setting is
created by this change.

The bootstrap resources are:

- `github_repository.asterisk_telephony` — public, initialized `main`, squash-only
  merges, secret scanning and push protection, deletion blocked in Terraform;
- `github_branch_default.asterisk_telephony` — default branch `main`;
- `github_repository_vulnerability_alerts.asterisk_telephony`;
- `github_repository_dependabot_security_updates.asterisk_telephony`;
- `github_workflow_repository_permissions.asterisk_telephony` — read-only default
  workflow token and no workflow-generated PR approvals.

Use the established remote backend; do not migrate state or switch to a new
workspace. A plan targeting exactly these five addresses must contain only new
resources and the new repository output. Existing repository drift is a separate
change and must not be applied as a side effect. Review the saved remote plan,
apply that exact plan, verify the public repository and security settings through
GitHub, then repeat the scoped plan to confirm no changes.

`auto_init` creates the initial README commit. Publish reviewed source through a
normal fast-forward commit on that history; do not force-push a second root over
it. Bootstrap deliberately does not add a main-branch ruleset requiring checks
that do not yet exist. Any later ruleset must use the companion's actual successful
check name and a separately reviewed Terraform change. No bot grant is implied.

## Review and source-analysis policy after bootstrap

The separate `github_repository_ruleset.asterisk_telephony` resource protects the
existing default branch. It requires one current approval, resolution of review
threads, and up-to-date successful checks: `test`, both
`home-assistant-runtime` requirements profiles, and the `CodeQL` result. The first
three checks are bound to GitHub Actions (`15368`); the CodeQL result is bound to
its own app (`57789`). These names and app identities were verified on the source
analysis pull request. Do not substitute a nonexistent `CI gate` check.

The existing `public_release_reviewers["asterisk-telephony"]` resource grants
`californiantiramisu` repository-scoped Write access so its review can satisfy the
rule. Organization owners retain the established maintenance bypass; the bot
receives neither administration nor bypass. The workflow-token permissions and
organization-secret allowlists remain unchanged.

Apply this stage only after reviewing a plan restricted to the new ruleset and
this one collaborator grant. Existing repository, billing, secret, and other
ruleset changes are outside its scope. If either object already exists, import
its exact identity instead of creating a duplicate. After apply, verify effective
Write access, the active default-branch rules, and all four required check names
and app IDs. Reconcile the unsupported extra approval flag using the
[existing review-policy procedure](public-security.md#extra-copilot-approval-after-terraform).
A committed policy is not evidence of a completed apply.

Recovery preserves repository identity and HCP state: `prevent_destroy` rejects
accidental removal, and `archive_on_destroy` is a second safeguard rather than an
automatic rollback action. Correct settings at the same Terraform addresses. Do
not delete or recreate the repository to undo a failed source publication.
