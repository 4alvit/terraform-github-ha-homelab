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
and app IDs. A committed policy is not evidence of a completed apply.

The provider does not preserve `require_extra_approval_for_unattributed_changes`.
Use this Asterisk-only inspection after apply; do not run the owner-wide
reconciliation command for this rollout. It requires exactly one matching active
ruleset and preserves every other writable field. Review its output first. To
apply the single flag correction, change the invocation to
`python3 - --apply <<'PY'`; an original-body receipt is saved locally before the
write, and the current body is checked again to reject concurrent changes.

```bash
python3 - <<'PY'
import copy
import json
from pathlib import Path
import subprocess
import sys

if not __debug__:
    raise RuntimeError("Run without Python optimization; guards must be enabled")

repo = "ha-homelab/asterisk-telephony"
def api(path, body=None, *, pages=False):
    args = ["gh", "api", path]
    if pages:
        args += ["--paginate", "--slurp"]
    if body is not None:
        args += ["--method", "PUT", "--input", "-"]
    value = json.loads(subprocess.check_output(
        args, input=json.dumps(body) if body is not None else None, text=True))
    return [item for page in value for item in page] if pages else value

def writable(value):
    return {key: value[key] for key in (
        "name", "target", "enforcement", "bypass_actors", "conditions", "rules")}

matches = [rule for rule in api(f"repos/{repo}/rulesets?per_page=100", pages=True)
           if rule["name"] == "Asterisk required CI and review"
           and rule["source_type"] == "Repository" and rule["source"] == repo]
assert len(matches) == 1, "Expected one Asterisk-owned ruleset"
endpoint = f"repos/{repo}/rulesets/{matches[0]['id']}"
original = api(endpoint)
before = writable(original)
assert before["target"] == "branch" and before["enforcement"] == "active"
after = copy.deepcopy(before)
reviews = [rule for rule in after["rules"] if rule["type"] == "pull_request"]
assert len(reviews) == 1 and reviews[0]["parameters"]["required_approving_review_count"] == 1
reviews[0]["parameters"]["require_extra_approval_for_unattributed_changes"] = False
print(json.dumps({"endpoint": endpoint, "change_needed": before != after}))
if before != after and sys.argv[1:] == ["--apply"]:
    folder = Path.home() / ".codex/artifacts/asterisk-review-policy"
    folder.mkdir(mode=0o700, parents=True, exist_ok=True)
    receipt = folder / f"ruleset-{original['id']}-before.json"
    with receipt.open("x") as stream:
        receipt.chmod(0o600)
        json.dump(original, stream, indent=2)
    assert writable(api(endpoint)) == before, "Ruleset changed; inspect again"
    api(endpoint, after)
    assert writable(api(endpoint)) == after, "Readback differs; inspect the receipt"
    print("Verified Asterisk-only flag correction")
PY
```

If a receipt already exists, inspect the previous result instead of overwriting
it or automatically repeating the write. This procedure never changes review
counts, another repository, or an organization ruleset.

Recovery preserves repository identity and HCP state: `prevent_destroy` rejects
accidental removal, and `archive_on_destroy` is a second safeguard rather than an
automatic rollback action. Correct settings at the same Terraform addresses. Do
not delete or recreate the repository to undo a failed source publication.
