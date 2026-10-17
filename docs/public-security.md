# Public software security policy

`public-security.tf` lists the public repositories reviewed for this rollout.
Live metadata excludes private and archived repositories from new protections.
The public `ha-desloc` integration always requires one current approval, dismisses
stale approvals, requires approval after the last push, resolves review threads,
and has no bypass actors. Its existing `Protect main` ruleset also requires the
strict `CI gate` check bound to GitHub Actions (integration ID `15368`). The gate
is supplied by the integration's existing shared CI workflow. An empty
`public_security_enforcement_repositories` value cannot disable this policy.
Live visibility and archive checks still apply.

The other five audited public repositories preserve their current administrator
bypass and review settings by default. Set
`public_security_enforcement_repositories` only for repositories whose approval
automation has been verified; activation enables the same current-review policy
without administrator bypasses.
This explicit activation does not affect the already active one-review policies
for the button, Tuya conversion, and public Home Assistant repositories.
Existing mandatory status checks and enabled auto-merge settings are preserved.

The public Home Assistant repository requires `CI gate`, `check-0 / validate`,
and `check-0 / maintenance-runtime`, all bound to GitHub Actions (integration
ID `15368`) with strict up-to-date checks. The `check-0 /` prefix is part of the
published check name from the reusable workflow. Keep these exact names in
Terraform when reconciling the shared pipeline; the old unqualified names do
not describe the checks that current pull requests produce. The existing
one-review policy, stale approval dismissal, latest-push approval, resolved
threads, and absence of bypass actors remain required.

`zac93-esp32` retains its enabled auto-merge setting. Auto-merge still waits for
the repository's strict `check` and `secrets` checks, and adds no ruleset bypass.
Policy tests cover these established settings so a later apply cannot silently
disable auto-merge or replace active checks with obsolete names.

Secret scanning and push protection are enabled on the audited public repository
resources managed by this state. Private vulnerability reporting was enabled
separately through GitHub's repository API; the pinned Terraform provider does
not expose that setting. Verify it under repository security settings during
onboarding. Do not put a credential in a commit to test push protection.

New public repositories may set `enable_secret_scanning = true` in the declared
inventory, so protection is enabled during creation without querying a repository
that does not exist yet. The visibility guard still excludes private repositories.
`zigbee-direct-button` uses this path and has its own ruleset with one
current approval and no bypass. During initial provisioning, create only its
repository, default branch, and security-update resources with a reviewed targeted
plan; publish the initial source, then apply its ruleset and run a complete plan.
The final configuration must include the ruleset. This bootstrap sequence does
not relax rules on any existing repository.

## Rollout and state ownership

Merge the application repair PRs after their required checks succeed, then
reconcile this desired configuration with the canonical state. Do not perform a
fleet-wide apply from an empty or unrelated state. If a rule was created through
the API, import its actual repository/ruleset identity at the declared address
before applying; do not create a duplicate rule. For out-of-band setting changes,
refresh and inspect the plan to verify the source preserves them.

For the DESLOC policy repair, retain the existing resource address
`github_repository_ruleset.desloc` and remote ruleset ID `24293264`. Review a
targeted plan for that resource in the canonical HCP workspace, then verify the
live default-branch rules and required check identity after applying. A full plan
must still be inspected for unrelated drift; do not apply other repositories'
changes as part of this repair. The separate card repository is outside its scope.

One current approval from a reviewer with Write access satisfies the review
count. Automation may provide that approval; it does not replace the required CI
checks or resolution of review threads. Keep the count at one when reconciling
Terraform with GitHub so a later apply cannot restore a two-review requirement.

## Extra Copilot approval after Terraform

GitHub's `require_extra_approval_for_unattributed_changes` setting must be
`false`: otherwise an unattributed Copilot PR needs an extra approval even when
the configured count is one. The pinned GitHub provider does not expose this
field, and sending a ruleset without it restores GitHub's default `true`.

After a ruleset apply or creation, run the shared
[review-policy reconciliation script](https://github.com/4alvit/terraform-github-4alvit/blob/main/scripts/reconcile-review-policy.py)
with `--owner OWNER` to inspect that owner's rules. Use `--apply --backup-dir DIR`
to save the current bodies, change only review counts above one and the extra
approval flag, and verify that all other protections remain intact. Choose a new
local backup directory for each application. Rules without required approvals
keep their zero count; archived repositories stay read-only and are reported.
This step is required until the provider supports the
extra-approval field; a Terraform plan alone cannot validate it.

## Trust boundaries

Terraform credentials can change repository governance; store them in the
canonical workspace's secret variables with the narrow required scope. Source
reviews must consider changed repository sets, ruleset bypasses, workflow token
permissions, release gates and remote object ownership. Validation runs use no
production state or credentials. Provider schemas and mock tests establish
configuration behavior, not the correctness of a future live apply.

## OpenSSF evidence and remaining assessment

Public Git history, the MIT license, README interfaces, contribution policy,
private reporting instructions and executable mock tests provide auditable
inputs for an OpenSSF Best Practices assessment. The new tests cover current
review requirements and exclusion of private/archived repositories. Required
CI results and actual live settings must be checked after merge.

No OpenSSF award is claimed by this document. Maintainer knowledge, external
report-response history, release-note applicability, full static-analysis scope
and all remaining mandatory criteria need individual verification. A repository
is not certified because its managed applications are certified or vice versa.

## Public Home Assistant CI approval

`github_workflow_repository_permissions.home_assistant_public` allows GitHub
Actions to create approving PR reviews while preserving `read` as the default
workflow permission. The public HA configuration workflow grants
`pull-requests: write` only to its metadata-only approval job, after both required
CI jobs pass, for same-repository owner PRs carrying the explicit `auto-approve`
label. The branch rules still require a current approval, successful checks and
resolved discussions; no bypass actor is added.

Rollback: set `can_approve_pull_request_reviews` back to `false` and apply that
resource. Remove the opt-in label to stop a pending individual approval.
