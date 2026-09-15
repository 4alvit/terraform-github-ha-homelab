# HA Homelab GitHub infrastructure

[![Terraform CI](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml/badge.svg)](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml)

Terraform manages the repositories of [HA Homelab](https://github.com/ha-homelab).
This public project contains repository settings only. Home Assistant configuration,
automations, scripts, household data, and credentials belong in private repositories.

## Ownership

- `ha-homelab/automations` — private Home Assistant automations.
- `ha-homelab/scripts` — private reusable Home Assistant scripts.
- `ha-homelab/home-assistant` — private configuration and deployment guidance.
- `ha-homelab/.github` — public organization profile and original logo assets.

Repository contents and deployment workflows are maintained in those repositories.
This project does not deploy or reload Home Assistant. Its own repository settings
belong to [terraform-github-4alvit](https://github.com/4alvit/terraform-github-4alvit).
The GitHub organization already exists; organization creation and avatar selection
are not supported by this Terraform configuration.

## HCP Terraform

The canonical remote workspace is
[`victron-venus/github-ha-homelab-infrastructure`](https://app.terraform.io/app/victron-venus/workspaces/github-ha-homelab-infrastructure).
It uses Terraform **1.15.7**, remote execution, remote state, and manual apply approval.
The HCP organization follows the existing personal-account infrastructure convention;
the target GitHub organization is `ha-homelab`.

Set `github_token` as a **sensitive Terraform-category workspace variable** with HCL
disabled. Use a credential authorized to administer these repositories. Keep its
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

GitHub Free does not enforce branch protection for private repositories. Those repos
use reviewable pull requests and CI as a workflow convention; this is not a claim of
server-enforced protection. The public profile repo protects `main` from deletion and
force pushes, with an administrator bypass for bootstrap and recovery. No paid
security features or subscriptions are enabled by this configuration.

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
