# Public software security policy

## Emergency owner merges

The owner policy approved on 2026-10-27 permits organization owners (`OrganizationAdmin`, with no actor ID)
to bypass branch requirements **only while merging a pull request**. The shared
`owner_emergency_merge_actor` in `admin-merge-policy.tf` is attached to each
managed branch ruleset, including separate review and CI gates. A grant on only
one ruleset cannot override another applicable rule. Existing unrelated actor
exceptions are preserved; this change does not grant automation new privileges.

Ordinary merges retain their existing reviews, CI, signatures and resolved-thread
requirements. Use the exception deliberately for a necessary recovery, record the
reason and available validation in the PR, and follow up on skipped checks. The
new grant cannot authorize a direct push, force push, branch deletion or tag
rewrite. Immutable release tags and deployment-environment approvals are unchanged.
Archived repositories remain read-only; existing archived release gates receive
no new actor. Repositories without enforced protection need no bypass grant.

Apply only a reviewed plan against the canonical existing HCP state, then read
back every applicable repository and inherited organization ruleset. An existing
classic branch protection can still prohibit bypass; it needs its own reviewed
state-managed update. Reconcile the unsupported extra Copilot approval field as
described below, preserving the actor list. A merge of this source is not proof
that HCP or GitHub has been updated.

OpenSSF Best Practices and OpenSSF Scorecard are separate assessments. This
exception is an explicit governance tradeoff: do not claim maximum branch
protection or universal two-person review. Reassess the actual badge criteria
and published evidence after any use that skips independent review. The
presence of a badge does not approve an emergency merge.

`public-security.tf` lists the public repositories reviewed for this rollout.
Live metadata excludes private and archived repositories from new protections.
The public `ha-desloc` integration requires pull requests, resolved review
threads, protected history, and the strict `CI gate` check bound to GitHub Actions
(integration ID `15368`), with the documented owner emergency exception. Its review policy is either one
current native approval or the quota-aware `Review policy` check described below.
An empty `public_security_enforcement_repositories` value cannot remove these
protections. Live visibility and archive checks still apply.

## DESLOC review quota policy

`desloc_quota_review_policy_enabled` selects the review mechanism for the public,
active `ha-desloc` repository only. Its versioned default is `true`; deploy and
verify the gate before merging or applying this transition. Setting it to `false`
restores one native approval, stale-approval dismissal, and approval after the
last push. Enabling it replaces the native approval count with the strict
`Review policy` check, also bound to
GitHub Actions (`15368`). The existing `CI gate`, required pull requests, resolved
threads, the owner emergency exception, and deletion/force-push protection remain in force.
The card and all other repositories are unchanged.

The trusted workflow normally requires an approval on the current pull-request
head from the authentic CodeRabbit bot or a collaborator with Write, Maintain,
or Admin access, excluding the pull-request author. Its limited exception is an
authentic CodeRabbit commit status for that same head whose latest status is
successful and reports `Review rate limited`. A missing status, an ordinary skip,
a pending review, an unrecognized error, or an older-head result cannot establish
that exception. An outstanding trusted `CHANGES_REQUESTED` review blocks either path.
The gate does not create an approving review to satisfy GitHub's counter.

This intentionally replaces native last-pusher independence with author
independence: an eligible reviewer who pushed the last commit can satisfy the
workflow policy if they are not the pull-request author. A quota exception also
allows merging without a completed CodeRabbit review; CI and thread resolution
are still required. GitHub's native approval count cannot express this conditional
exception, so its count becomes zero and `require_last_push_approval` becomes
false together with adding the required gate. Stale-review dismissal remains
enabled, and the workflow itself only accepts current-head approvals.

The status producer must run trusted default-branch workflow code, inspect GitHub
metadata without executing pull-request code, and report against the exact head
it evaluated. Binding to GitHub Actions identifies the app, not an individual
workflow; changes to workflows and shared-workflow pins therefore remain part of
the repository's review trust boundary.

RF Airbridge also requires one current approval with the owner emergency exception, plus its actual
`test` and `Compile ESPHome example` checks, bound to GitHub Actions
(`15368`) and an up-to-date branch. Its shared metadata-only bot approval is
opted into with `automerge`. Merge and verify that workflow before applying the
RF ruleset change; then read back the live approval count and both check names.
This activates the previously deferred policy, without creating a parallel ruleset.

The other four audited public repositories preserve their current administrator
bypass and review settings by default. Set
`public_security_enforcement_repositories` only for repositories whose approval
automation has been verified; activation enables the same current-review policy
with the documented owner emergency exception.
This explicit activation does not affect the already active one-review policies
for the button, Tuya conversion, and public Home Assistant repositories.
Existing mandatory status checks and enabled auto-merge settings are preserved.

Echo Dot requires the strict `CI gate` check from GitHub Actions (`15368`)
independently of optional review activation. A neutral review-bot status is not
source validation. Its existing review activation and administrator-bypass
settings remain unchanged by this CI requirement. After applying the reviewed
Terraform plan, read back the default-branch rules and verify the check name,
application ID and strictness before closing the enforcement issue.

The public Home Assistant repository requires `CI gate`, `check-0 / validate`,
and `check-0 / maintenance-runtime`, all bound to GitHub Actions (integration
ID `15368`) with strict up-to-date checks. The `check-0 /` prefix is part of the
published check name from the reusable workflow. Keep these exact names in
Terraform when reconciling the shared pipeline; the old unqualified names do
not describe the checks that current pull requests produce. The existing
one-review policy, stale approval dismissal, latest-push approval, resolved
threads remain required for ordinary merges; the owner emergency exception is separate.

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
current approval and the owner emergency exception. During initial provisioning, create only its
repository, default branch, and security-update resources with a reviewed targeted
plan; publish the initial source, then apply its ruleset and run a complete plan.
The final configuration must include the ruleset. This bootstrap sequence does
not relax rules on any existing repository.

`ha-jbd-bms-card` follows the same bootstrap sequence. Its final `Protect main`
ruleset requires one current independent approval, resolved review threads,
protected history and the strict `CI gate` check bound to GitHub Actions
(`15368`), with the documented owner emergency exception. Workflow tokens default to read-only and cannot
approve pull requests. Provision its repository, default branch, vulnerability
alerts, Dependabot updates and workflow permissions first; publish and verify
the reviewed source with a GitHub Actions workflow that runs `CI gate` on both
pushes and pull requests. Wait for the initial `CI gate` run to succeed before
applying `github_repository_ruleset.jbd_bms_card`.
Inspect the full final plan for unrelated drift rather than applying it blindly.

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

For the quota-policy transition, use this order:

1. Merge the shared policy workflow and DESLOC adapter while the existing native
   approval requirement is still active. Verify that the trusted workflow creates
   a `Review policy` result on the current head of an open DESLOC pull request.
   Check the review-required and quota-exception behavior with the policy tests.
2. After that verification, review and merge the Terraform transition whose
   versioned `desloc_quota_review_policy_enabled` default is `true`. Do not rely on
   a one-off CLI `-var` override or an undocumented workspace variable that a
   future plan could reverse. Merging source does not apply the HCP state.
3. From that reviewed commit, initialize the existing HCP workspace
   `victron-venus/github-ha-homelab-infrastructure` and inspect a targeted plan:
   `terraform plan -target=github_repository_ruleset.desloc`. It should modify the
   existing ruleset, add `Review policy`, set the native count to zero and disable
   last-push approval, while preserving `CI gate`, strictness, thread resolution,
   protected history and the owner emergency exception. Do not apply unrelated changes.
4. Apply only that reviewed transition in the canonical remote workspace, then
   read back ruleset `24293264` and the pull-request checks. Verify both required
   contexts use integration ID `15368`, the current-head policy result is present,
   and `require_extra_approval_for_unattributed_changes` is false. The provider
   limitation below requires a separate check even after a clean Terraform plan.
5. Inspect a full plan for remaining drift without applying other repositories'
   changes. Verify the card ruleset is unchanged. Retain the workflow and its
   event-driven/manual refreshes for later pushes and review changes.

Rollback is a reviewed change setting `desloc_quota_review_policy_enabled` to
`false` and applying the same existing resource. It restores the native current
approval and last-push requirements while removing the required `Review policy`
context. It preserves the other protections and retains the separately declared owner exception. Do this
before removing or renaming the status-producing workflow.

Repositories that continue using native review counts require one current
approval from an eligible reviewer; those counts must not be raised to two when
reconciling Terraform with GitHub.

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
For a DESLOC-only transition, do not run the owner-wide mutation as an incidental
cleanup: if the flag changed, save and reconcile only ruleset `24293264`, preserving
its other fields, and verify the live result.

Use this scoped command after the Terraform apply. It requires authenticated
`gh` and `jq`, saves a private backup, changes only the extra-approval flag, and
compares all writable settings after reading the rule back. An already-correct
rule needs no write. Run it without concurrent ruleset edits.

```sh
set -eu
umask 077
backup_dir=$(mktemp -d "${TMPDIR:-/tmp}/desloc-review-policy.XXXXXX")
endpoint=repos/ha-homelab/ha-desloc/rulesets/24293264
settings='{name, target, enforcement, bypass_actors, conditions, rules}'
gh api "$endpoint" > "$backup_dir/before.json"
jq -e '.id == 24293264 and .source_type == "Repository" and
  .source == "ha-homelab/ha-desloc" and
  ([.rules[] | select(.type == "pull_request")] | length == 1)' \
  "$backup_dir/before.json" > /dev/null
jq -S "$settings" "$backup_dir/before.json" > "$backup_dir/settings.json"
jq -S '(.rules[] | select(.type == "pull_request") |
  .parameters.require_extra_approval_for_unattributed_changes) = false' \
  "$backup_dir/settings.json" > "$backup_dir/desired.json"
if ! cmp -s "$backup_dir/settings.json" "$backup_dir/desired.json"; then
  gh api "$endpoint" > "$backup_dir/current.json"
  jq -S "$settings" "$backup_dir/current.json" > "$backup_dir/current-settings.json"
  cmp "$backup_dir/settings.json" "$backup_dir/current-settings.json"
  gh api --method PUT "$endpoint" --input "$backup_dir/desired.json" > /dev/null
fi
gh api "$endpoint" > "$backup_dir/after.json"
jq -S "$settings" "$backup_dir/after.json" > "$backup_dir/actual.json"
cmp "$backup_dir/desired.json" "$backup_dir/actual.json"
printf 'DESLOC review policy verified. Backup: %s\n' "$backup_dir"
```

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

### Existing public CI gates

The SLZB recovery policy requires the literal pull-request check `CI gate` from
GitHub Actions (app 15368), with strict current-base checking. Its existing review
activation settings are preserved. The existing public `k3s-self-healing`
repository has a dedicated default-branch policy with that same CI requirement,
one current independent review, resolved review threads, and deletion/force-push
protection with the documented owner emergency exception. Nested release runs show `checks / CI gate`;
that display name is not used for the pull-request requirement.

Apply only after reviewing the complete current plan and qualifying the public
k3s metadata-only reviewer workflow. Read back the full rulesets afterward,
including `require_extra_approval_for_unattributed_changes=false`, because the
provider can reset that additional-approval flag. Source tests do not establish
that the live policy is enabled.

The public JBD battery card is included in the existing scoped reviewer
allowlist. Its bot receives repository Write permission so an independent
approval can satisfy protection; the grant adds neither administration nor
rule bypass, and does not change the one-review or CI requirements.
