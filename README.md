# HA Homelab GitHub infrastructure

[![Terraform CI](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml/badge.svg)](https://github.com/4alvit/terraform-github-ha-homelab/actions/workflows/ci.yml)

Terraform manages the organization profile settings and repositories of
[HA Homelab](https://github.com/ha-homelab).
This public project contains repository settings only. Home Assistant configuration,
automations, scripts, household data, and credentials belong in private repositories.

## Public project ownership

- `ha-homelab/terraform-cloudflare-home-assistant` — reusable Cloudflare Tunnel
  and Home Assistant Terraform configuration with synthetic examples and private
  deployment inputs. No deployment domain, account identifiers, state, credentials
  or household inventory is published. See the [scoped provisioning procedure](docs/cloudflare-home-assistant-provisioning.md).

- `ha-homelab/asterisk-telephony` — reusable Home Assistant/Asterisk companion
  with AMI event bridging, phone entities, call actions and deployment guidance.
  Household topology, SIP/AMI credentials and Cisco firmware remain outside the
  public repository. Its bootstrap grants no bot access or runner infrastructure;
  see [the scoped provisioning procedure](docs/asterisk-telephony-provisioning.md).

- `ha-homelab/ha-radio-hub` — modular single-input PoE radio appliance,
  ESPHome firmware, local OTBR deployment, original wiring and printable CAD.
  Existing RF credentials, learned codes and network backups remain private.

The reusable adapters in `public-adapters.tf` start with fresh public history:

- `ha-ottplay` — media-player entities for OTTPlay devices registered with its
  remote control server, with HACS installation and local Home Assistant setup.
- `ha-onvif-room-direction` — read-only camera direction mapped to configured areas.
- `ruview-home-assistant` — expiring per-node observations through MQTT discovery.
- `ha-access-session` — signed Access identity exchange and a restricted HA gateway.
- `sensing-evidence-kit` — independent labels and reproducible sensing characterization.

Each receives secret scanning and push protection, one independent PR approval,
the required `CI gate`, immutable version tags, and a main-only stable-release
environment. The existing review bot has Write access and receives only its own
membership in the existing `BOT_PAT` secret allowlist. Source and release pipelines
are owned by each project; no household configuration or Git history is migrated.
Public hosted runners execute their initial CI. The private home consumes reviewed
public versions while retaining deployment, geometry and device bindings privately.

- `ha-homelab/zac93-esp32` — illustrated ZAC93 bridge guide for ESP32-WROOM
  and ESP32-S3, with ESPHome configuration, Home Assistant setup and diagnostics.
  Local hooks and CI reject private artifacts and secrets; the default branch
  requires both `check` and `secrets` without a bypass. Wi-Fi/API credentials,
  firmware builds and Z-Wave controller backups remain private.

- `ha-homelab/ha-lg-tv-capture` — public, MIT-licensed LG webOS TV screen capture
  tooling and Home Assistant integration. Private floorplans consume the reusable
  code from this repository; household configuration, captured images and
  credentials stay private.

- `ha-homelab/zigbee-direct-button` — public Tuya button firmware for direct
  Zigbee group control: short-press toggle and hold-to-off, reproducible builds,
  Home Assistant setup, backup, upgrades, and troubleshooting. Credentials,
  household identifiers, and real network backups are excluded.

- `ha-homelab/rf-airbridge` — public ESPHome CC1101 RF gateway, MQTT code
  discovery, Home Assistant automation and transmission, with preserved motion
  sensors. Credentials and household-specific data are excluded.

- `ha-homelab/slzb-06-recovery` — public SMLIGHT SLZB-06 backup, core/radio
  upgrade, and legacy Ethernet recovery documentation and scripts. Firmware,
  network backups, keys, credentials, and household identifiers are excluded.

- `ha-homelab/ha-tuya-esphome` — public legacy Tuya ESP8266-to-ESPHome
  conversion tooling, Linux workbench setup, troubleshooting and Home Assistant
  Matter bridge guides for Google Home and Alexa. Credentials, firmware builds,
  session logs and household identifiers stay outside the public repository.
- `ha-homelab/ha-echo-show-5` — public Echo Show 5 Gen2 Android conversion,
  backup verification and Home Assistant Companion guides and tools.
  Firmware, backups, credentials and household data are excluded.
- `ha-homelab/ha-echo-dot` — public Echo Dot 2 conversion and Home Assistant
  integration guides, reproducible wake-word training and exact-runtime checks.
  Firmware, audio, trained weights, credentials and household data are excluded.
- `ha-homelab/ha-echomuse` — public EchoMuse deployment and Home Assistant
  integration for repurposed Echo Dot 2 devices. Device backups, credentials,
  recordings, and household identifiers are excluded. Bootstrap its repository,
  default branch, vulnerability alerts, and Dependabot security updates first;
  publish reviewed source and verify the `CI gate` before applying its ruleset.
- `ha-homelab/ha-techo5-dot` — public TECHO5 deployment and Home Assistant
  integration guides for repurposed Echo Dot devices, with a separate wiki and
  fresh public history. Firmware, device configuration, credentials, recordings
  and household inventory remain private. See the [two-stage provisioning
  procedure](docs/techo5-dot-provisioning.md).
- `ha-homelab/ha-desloc-card` — public Lovelace dashboard card for the DESLOC
  integration, distributed separately through HACS. Auto-merge is enabled;
  its active public default branch requires up-to-date PRs and the GitHub Actions
  `CI gate`. Review activation remains controlled by the existing policy.

- `ha-homelab/ha-desloc` — public, unofficial DESLOC C100 Plus integration for
  Home Assistant, including HACS packaging, source, tests, and documentation.
  Captures, account sessions, and household device data are excluded.
- `ha-homelab/.github` — public organization profile and original logo assets.

Repository contents and deployment workflows are maintained in those repositories.
`desloc-coderabbit.tf` grants `californiantiramisu` the Write role on the two
active, public DESLOC repositories so it can request CodeRabbit autofixes.
This is repository-scoped access, without an administrator role or ruleset bypass.
If GitHub creates collaborator invitations, the bot account must accept them
before autofix can run. Verify effective Write access and the CodeRabbit response;
a successfully posted command does not prove that an autofix was accepted.

This project does not deploy or reload Home Assistant. Its own repository settings
belong to [terraform-github-4alvit](https://github.com/4alvit/terraform-github-4alvit).
The existing organization settings are imported, preserving billing and access
defaults. Organization creation and avatar selection are outside this configuration.

## Home Assistant source repositories

`home-studio.tf` looks up the existing public `ha-homelab/home-studio`
repository and manages only its default-branch CI ruleset. Pull requests must
pass the exact `CI gate` check from GitHub Actions (integration `15368`), with
strict up-to-date checks and no bypass actors. The gate aggregates Home Studio's
required package, browser, installation and workflow checks. No additional review
count or merge-method restriction is introduced. Repository settings, collaborators,
secrets and release environments are outside this resource's ownership.

`home-studio-closed-build.tf` separately adopts the existing `closed-build`
environment and its `main` deployment branch policy. Jobs require approval from
`4alvit`; administrators cannot bypass that review. The existing single-maintainer
policy permits the owner to approve a run they triggered. Encryption keys and
storage credentials remain operator-managed outside Terraform state.
The import blocks retain the existing environment and branch-policy identities.
Apply only a reviewed plan for these two resources; adoption should import them
without changing live settings. To stop Terraform ownership, remove the resources
from state without destroying the environment or its retained secrets.
Run `python3 scripts/check-closed-environment.py` before and after each scoped
plan/apply; CI also runs this anonymous, metadata-only check. Provider 6.13.0 can
retain a stale reviewer in state after the last live reviewer is removed, so a
clean Terraform plan alone does not prove that approval is still required.

Before applying, verify the live check name and app identity, then review a remote
plan targeted to `github_repository_ruleset.home_studio_ci`. It should create only
that ruleset. A failing Home Studio gate must block merging; changing the ruleset
does not fix or waive browser failures. Validate the live default-branch rules after
apply and retain the reviewed plan outside this public repository.

`home-assistant-private` retains the predecessor's private Git history at the
existing `github_repository.repositories["home-assistant"]` Terraform address.
The separately provisioned public `home-assistant` repository is owned by
`github_repository.home_assistant_public` and starts from a sanitized file
snapshot with bundled automation and script libraries. The old component
repositories stay private. See [publication procedure](docs/home-assistant-publication.md).

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

The owner decided on **2026-09-25** to keep GitHub Free and leave private
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
The public `ha-desloc` integration requires pull requests, resolved review threads,
protected history, and the strict GitHub Actions `CI gate`, without bypasses.
The `desloc_quota_review_policy_enabled` transition replaces its native approval
count with a required `Review policy` check after that workflow has been verified.
The workflow requires a current-head approval except for a verified CodeRabbit
quota result; requested changes still block merging. This changes reviewer
independence from last-pusher independence to pull-request-author independence.
An empty `public_security_enforcement_repositories` value cannot remove the
mandatory protections. The existing ruleset is updated in place, and the card's
ruleset is unchanged. RF Airbridge retains its mandatory current-review policy;
the other four audited public repositories retain their current review and bypass
settings until explicitly activated through that variable. Existing required CI
checks remain in place.
See the [public security policy](docs/public-security.md) for activation and verification.
No private-repository access policy changes are implied.

### Existing repository ownership

The original repository inventory and canonical HCP state were reconciled
before adoption. Preserve the operator's inventory and import evidence outside
public documentation. A clean plan covers only resources already represented
in configuration and state; compare it with the authorized live inventory too.

When adopting another existing repository, add its configuration and an import
block for the existing `github_repository.repositories["name"]` resource before
applying; review the plan to avoid recreating or changing its visibility. Inventory
and import any existing default-branch, security-settings or ruleset resources at
their corresponding addresses as well. Never commit state or credentials.

## LG TV capture bootstrap

Provision `ha-lg-tv-capture` with its generated README, secret scanning, push
protection, Dependabot and read-only workflow-token defaults. Publish the reviewed
source and MIT license through a pull request, then activate
`github_repository_ruleset.lg_tv_capture` when the source workflow provides
`CI gate`. The ruleset requires one current approval without bypasses and allows
only squash merging. Auto-merge is available after the required checks and review.
Release workflows and source files are owned by the capture repository.

After the source PR is merged and its workflow checks pass, enable release
publication through `github_actions_variable.lg_tv_capture_release_publication`.
It depends on the protected version tags and the `release` environment, whose
deployment policy allows only `main` and whose reviewer is `4alvit`. The environment
follows the existing single-maintainer policy: the owner may approve a promotion
they triggered and administrators may bypass environment approval. Branch and
version-tag rulesets have no bypass actors. No production environment is created.

Review a targeted remote plan for the new repository's resources during this
bootstrap; do not apply unrelated workspace drift. Finish with a new remote plan
and verify the live public visibility and protections.

## Activate the public adapter reviewer

Creating a `github_repository_collaborator` can leave a pending invitation. Until
the bot accepts it, GitHub may let it post a review as a public reader without
counting that review toward branch protection. After the public adapter or RuView reviewer resources have been applied, run the metadata-only workflow from `main`:

```sh
gh workflow run accept-adapter-reviewer.yml --ref main
```

The existing `BOT_PAT` must belong to `californiantiramisu`. The workflow accepts
only that user's write invitations for the four repositories in
`local.public_adapters` and `ha-homelab/ruview-home-sensing` plus
`ha-homelab/terraform-cloudflare-home-assistant`. It does not create permissions, accept other invitations,
check out source, approve PRs, or bypass protections. Re-running is safe: already
accepted invitations are no longer returned. Verify the bot has `write`
permission, then rerun each repository's normal review workflow if necessary.

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

## Contributions and public security

See [CONTRIBUTING.md](CONTRIBUTING.md) for bug reports, proposed changes and tests,
[SECURITY.md](SECURITY.md) for private vulnerability reports, and
[public security policy](docs/public-security.md) for review requirements,
secret protection and rollout/state ownership. OpenSSF readiness is assessed
for this infrastructure repository separately from the projects it manages.

## EchoMuse documentation wiki

The `ha-echomuse` entry explicitly enables its public GitHub wiki. Entries without
an explicit opt-in retain `has_wiki = false`; enabling documentation here
changes neither repository visibility nor branch/review protection.

The source documentation and reproducible wiki exporter live in
[ha-echomuse](https://github.com/ha-homelab/ha-echomuse). Keep operational secrets,
recordings and live device inventories out of both repositories. GitHub requires
an initial wiki page before its separate Git repository can be cloned; content
publication is performed from reviewed documentation after enabling the wiki.

For this narrowly scoped change, inspect a remote plan targeted to
`github_repository.repositories["ha-echomuse"]`. Apply only if the planned
resource change is the wiki flag. Do not apply unrelated organization drift as
part of documentation publication.

## Public community tools and illustrated documentation

Four independent offline tools are managed in `community-tools.tf`:
[entity migration plans](https://github.com/ha-homelab/ha-entity-migrations),
[meter contracts](https://github.com/ha-homelab/ha-meter-contracts),
[Home Assistant scenarios](https://github.com/ha-homelab/ha-scenario-tests), and
[Assist evidence evaluation](https://github.com/ha-homelab/assist-scenario-lab).
Their READMEs and CLI support English, Russian, German and Spanish. Detailed
EN/RU guides and separately published GitHub wikis use synthetic examples.
The [community overview](https://github.com/ha-homelab/.github/tree/main/community-tools)
explains how the tools relate and records the remaining hardware work.

These repositories require signed commits and pull requests with successful
`check` and `secrets` checks; there are no bypass actors. Secret scanning and
push protection are enabled. The initial repositories are adopted through
explicit import blocks; do not create duplicate state ownership. ZAC93 also
opts into its documentation wiki without changing radio or firmware settings.

Apply a reviewed HCP plan scoped to the four new repository identities, default
branches, vulnerability/security update settings and rulesets, plus only the
ZAC93 repository wiki flag. Do not include unrelated workspace drift. Inspect
the planned resource addresses before applying, then verify a fresh scoped plan.

## Maintenance and verified operation

See the [supported TLS profile](docs/TLS_PROFILE.md), [assessment evidence](docs/openssf-evidence.md), [governance](GOVERNANCE.md), [Code of Conduct](CODE_OF_CONDUCT.md), and [one-year roadmap](ROADMAP.md).

[![OpenSSF Best Practices](https://www.bestpractices.dev/projects/15575/badge)](https://www.bestpractices.dev/projects/15575)

The [disclosed secure-provider profile](docs/SECURE_PROVIDER.md) builds a reviewed patched GitHub provider, validates an isolated source copy and supports a guarded independent local deployment with OpenTofu; production locks and state are not automatically changed. The [engine advisory assessment](docs/OPENTOFU_ADVISORIES.md) is dated and scoped.

## Public RuView implementation

`ruview-home-sensing.tf` creates [ha-homelab/ruview-home-sensing](https://github.com/ha-homelab/ruview-home-sensing) as an independent public repository. Publication uses reviewed generic source and a new Git history; no existing repository changes visibility. Installation configuration, device identities, credentials, observations and floor plans are excluded from this repository.

The initial repository has secret scanning and push protection, vulnerability alerts, Dependabot security updates, read-only default workflow permissions, and approval support for explicitly authorized metadata workflows. `CI_RUNNER_MODE=github` overrides organization routing so shared workflows use GitHub-hosted runners. The project also checks that policy before launching its shared validation. Main requires one current independent approval, resolved review threads, the `Public CI gate` check from GitHub Actions, and the separate `CodeQL` result from GitHub Advanced Security, with no bypass actors. A successful SARIF upload does not bypass security findings. Automatic merging is enabled, but both validation checks and current independent approval remain mandatory. Version tags matching `v*` cannot be updated or deleted; new release tags remain permitted.

Provisioning is a reviewed targeted HCP plan containing only the twelve RuView resources (the runner variable is `ruview_home_sensing_hosted` and the version-tag ruleset is `ruview_home_sensing_tags`). Check for unexpected addresses or non-create actions before the first apply. Existing organization repositories are outside this bootstrap scope. Repository files and application releases remain owned by their source PRs.

Private vulnerability reporting is enabled through GitHub's repository API. Provider 6.13.0 does not expose this setting, so it is a documented external setting rather than a Terraform-managed attribute. Verify `GET /repos/ha-homelab/ruview-home-sensing/private-vulnerability-reporting` returns `enabled: true` after repository recovery.

The repository must be created with `auto_init=false`. A generated GitHub README commit can use account author metadata rather than an explicit public identity. Bootstrap an empty repository with a reviewed root commit whose author and committer both use the intended public login and GitHub noreply address. Apply the repository shell and its security/workflow settings first, push the clean root commit, and then apply the default branch and ruleset. The initial empty bootstrap was recreated before publishing application source to enforce this boundary; no prior application history was transferred.

### Reviewed approval and merge automation

The existing organization `BOT_PAT` is granted only to the public RuView repository, and `californiantiramisu` receives Write access without administration or rule bypass. Terraform manages only that secret allowlist membership, never the credential value. The `auto-approve` and `automerge` labels express separate approval and merge requests. Accept the scoped reviewer invitation before expecting its approval to satisfy protection.

This infrastructure repository uses metadata-only reusable approval and reviewed single-pass merge workflows pinned to `victron-venus/venus-os-ci-toolkit` commit `21a366f200f0371a10a6de7ad6ca263af230b842`. For same-repository branches authored by the maintainer with verified public no-reply identity, add `auto-approve` to request the existing independent bot review, and `automerge` to request squash merge after all reported checks succeed, including `Terraform validation` and `CodeQL`. The merge evaluator verifies the exact head, current default branch and approval repeatedly; it does not use native auto-merge or bypass protection. Completion events and a recovery schedule re-evaluate waiting requests. These jobs never check out or execute pull-request code. Bot-authored PRs require an explicit public no-reply author identity at manual squash merge until that account's merge identity is verified; the reviewer remains `californiantiramisu`.

### Public release reviewers

`public-release-reviewers.tf` gives the existing `californiantiramisu` reviewer
repository-scoped Write access to the thirteen explicitly listed public release,
validation, and security-maintenance projects: `.github`, `assist-scenario-lab`,
`ha-echo-dot`, `ha-echo-show-5`, `ha-entity-migrations`, `ha-meter-contracts`,
`ha-scenario-tests`, `home-assistant`, `home-studio`, `k3s-self-healing`,
`rf-airbridge`, `slzb-06-recovery`, and `zac93-esp32`. Read-only organization
membership cannot provide an approval that satisfies protected branch rules. Each target must
remain public and active. The grant does not change required CI, approval counts,
last-push review, secret access, runner selection, or rule bypasses.
