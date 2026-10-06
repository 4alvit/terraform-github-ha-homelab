# HA Homelab GitHub infrastructure

[![Terraform CI](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml/badge.svg)](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml)

Terraform manages the organization profile settings and repositories of
[HA Homelab](https://github.com/ha-homelab).
This public project contains repository settings only. Home Assistant configuration,
automations, scripts, household data, and credentials belong in private repositories.

## Ownership

- `ha-homelab/slzb-06-recovery` — public SMLIGHT SLZB-06 backup, core/radio
  upgrade, and legacy Ethernet recovery documentation and scripts. Firmware,
  network backups, keys, credentials, and household identifiers are excluded.

- `ha-homelab/ha-echo-show-5` — public Echo Show 5 Gen2 Android conversion,
  backup verification and Home Assistant Companion guides and tools.
  Firmware, backups, credentials and household data are excluded.
- `ha-homelab/ha-echo-dot` — public Echo Dot 2 conversion and Home Assistant
  integration guides, reproducible wake-word training and exact-runtime checks.
  Firmware, audio, trained weights, credentials and household data are excluded.
- `ha-homelab/ha-desloc-card` — public Lovelace dashboard card for the DESLOC
  integration, distributed separately through HACS.

- `ha-homelab/ha-desloc` — public, unofficial DESLOC C100 Plus integration for
  Home Assistant, including HACS packaging, source, tests, and documentation.
  Captures, account sessions, and household device data are excluded.
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

Visibility is explicit, repository destruction is blocked, and default
branches are `main`. Squash merges keep history readable and remove merged branches.
Dependabot security updates and vulnerability alerts are enabled where supported.

### Default branch protection

The owner decided on **2026-09-25** to keep GitHub Free and leave the four private
repositories without enforced branch protection. Access is limited to the trusted
household owners and their automation. Pull requests and successful CI remain the
working convention; they are not server-enforced merge requirements.

The `main`-is-unprotected warning is expected and accepted. Do not enable paid
Team solely for branch protection, make household configuration public, or treat
this warning as a pending repair. A future plan change must not automatically add
private rulesets or change auto-merge settings; either requires a new explicit
policy decision.

GitHub Free does not support enforced private-repository rulesets; see
[GitHub's availability documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets).
The public `.github` profile retains its existing active protection and
administrator bypass. Its Terraform resource address and remote ID are unchanged.
The public `ha-desloc` integration has a separate ruleset with pull requests,
resolved review threads, protected history, and the same administrator bypass.
The public `slzb-06-recovery`, `ha-desloc-card`, `ha-echo-dot` and `ha-echo-show-5` repositories follow that same
protection pattern. No private-repository access policy changes are implied.

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
```

The provider lock file is committed for reproducibility. Repository visibility is
also verified against GitHub after remote apply. Every infrastructure change should
end with a fresh remote plan showing no unintended changes.

## License

[MIT](LICENSE). This is an independent homelab project, not an official Home Assistant project.
