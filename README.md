# HA Homelab GitHub infrastructure

[![Terraform CI](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml/badge.svg)](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml)

Terraform manages the organization profile settings and repositories of
[HA Homelab](https://github.com/ha-homelab).
This public project contains repository settings only. Home Assistant configuration,
automations, scripts, household data, and credentials belong in private repositories.

## Ownership

- `ha-homelab/automations` — private Home Assistant automations.
- `ha-homelab/scripts` — private reusable Home Assistant scripts.
- `ha-homelab/home-assistant` — private configuration and deployment guidance.
- `ha-homelab/home-floorplan-3d` — private architectural source plans, reproducible
  3D exports, an offline placement viewer, and Home Assistant device mappings.
- `ha-homelab/.github` — public organization profile and original logo assets.

Repository contents and deployment workflows are maintained in those repositories.
This project does not deploy or reload Home Assistant. Its own repository settings
belong to [terraform-github-4alvit](https://github.com/4alvit/terraform-github-4alvit).
The existing organization settings are imported, preserving billing and access
defaults. Organization creation and avatar selection are outside this configuration.

## HCP Terraform

The canonical remote workspace is
[`victron-venus/github-ha-homelab-infrastructure`](https://app.terraform.io/app/victron-venus/workspaces/github-ha-homelab-infrastructure).
It uses Terraform **1.15.7**, remote execution, remote state, and manual apply approval.
The HCP organization follows the existing personal-account infrastructure convention;
the target GitHub organization is `ha-homelab`.

Set `github_token` as a **sensitive Terraform-category workspace variable** with HCL
disabled. Also set `billing_email` as a sensitive Terraform-category variable using
the existing organization billing email; importing settings must not change it.
Use a credential authorized to administer these repositories. Keep its
permissions limited to the target organization and operations in this configuration.
Do not commit credentials or Terraform state.

From a reviewed, clean commit:

```sh
terraform login
terraform init
terraform plan
terraform apply
```

The CLI uploads configuration and Terraform executes in HCP Terraform; it does not
apply against a local state file. Review the remote plan before confirming apply.
The workspace is CLI-driven, not VCS-connected: GitHub Actions checks formatting and
provider validation without credentials; merging a PR does not itself apply changes.

## Repository policy

Private visibility is explicit, repository destruction is blocked, and default
branches are `main`. Squash merges keep history readable and remove merged branches.
Dependabot security updates and vulnerability alerts are enabled where supported.

### Default branch protection

[`branch-protection.tf`](branch-protection.tf) reads the organization's current plan
from GitHub. GitHub Free does not support enforced branch protection or rulesets for
private repositories. On the verified **2026-09-25** plan (`free`), GitHub returns
HTTP 403 for both private ruleset and branch-protection APIs. A warning that `main`
is unprotected is therefore accurate; adding a Terraform resource cannot override
the entitlement. See [GitHub's ruleset availability](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets).

On Free, the `branch_protection` output lists all four private repositories under
`pending_private_repositories`. The public profile keeps its existing active
ruleset and administrator bypass; its resource address and remote ID are unchanged.

After the organization is upgraded to GitHub Team or Enterprise, the next reviewed
Terraform plan creates one active ruleset for each private default branch and
enables auto-merge. A paid subscription is a separate billing decision; Terraform
does not purchase or change it. The rules require:

- Pull requests using squash merge, with all review threads resolved. No second
  person's approval is required for this single-owner workflow.
- Successful checks on an up-to-date branch, bound to the GitHub Actions app:
  `validate` and `maintenance-runtime` for `home-assistant`;
  `Validate automation contracts` for `automations`;
  `Validate YAML and behavior contracts` for `scripts`;
  `validate` and `home-assistant` for `home-floorplan-3d`.
- No branch deletion, force pushes or routine administrator bypass. Normal
  administrator merges must also wait for CI.

The private rulesets use `prevent_destroy`, so a plan downgrade or inventory edit
cannot silently remove protection. An unavailable or unrecognized plan fails the
plan instead of claiming the repositories are protected. Renaming a required CI
job requires a matching change here.

To activate after a separately authorized plan upgrade, run the normal remote
`terraform plan` and `terraform apply` from a clean reviewed commit. Expect four
new private rulesets and auto-merge enabled for those four repositories. Then
verify `protected: true` on each default branch and finish with a no-change plan.
Do not make household configuration public to work around the plan restriction.

### Existing repository ownership

On **2026-09-25**, GitHub's five-repository inventory matched both
`local.repositories` and the canonical HCP state: `home-assistant`, `automations`,
`scripts`, `home-floorplan-3d` and `.github`. Repository settings, default branches,
vulnerability alerts and Dependabot security updates were already in state; the
public profile ruleset was also present. No repository import was needed.
The baseline remote plan reported no infrastructure changes.

When adopting another existing repository, add its configuration and an import
block for the existing `github_repository.repositories["name"]` resource before
applying; review the plan to avoid recreating or changing its visibility. Inventory
and import any existing default-branch, security-settings or ruleset resources at
their corresponding addresses as well. Never commit state or credentials.

## Validation

```sh
terraform fmt -check -recursive
terraform init -backend=false -input=false -lockfile=readonly
terraform validate
terraform test
```

The tests use a mocked GitHub provider to check Free, Team, Enterprise and missing
plan behavior without credentials, network access or changes to remote state.
The provider lock file is committed for reproducibility. Repository visibility is
also verified against GitHub after remote apply. Every infrastructure change should
end with a fresh remote plan showing no unintended changes.

## License

[MIT](LICENSE). This is an independent homelab project, not an official Home Assistant project.
