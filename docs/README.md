# Documentation

Terraform for the HA Homelab GitHub organization: organization profile settings
and repository settings for the public Home Assistant projects and the reusable
public adapters.

## Published Home Assistant projects

- [Provision the public Cloudflare/Home Assistant module](cloudflare-home-assistant-provisioning.md) — the metadata-only ownership of `ha-homelab/terraform-cloudflare-home-assistant`.
- [Asterisk telephony companion provisioning](asterisk-telephony-provisioning.md) — the new public `asterisk-telephony` repository and the settings Terraform owns for it.
- [Provision the public TECHO5 Dot repository](techo5-dot-provisioning.md) — the GitHub metadata owned for `ha-homelab/ha-techo5-dot` and the device work it excludes.
- [Home Assistant source publication](home-assistant-publication.md) — the fresh public history, and how the previous private repository and its workflow records are kept.
- [Review bot access for public projects](review-bot-access.md) — the six repository memberships granted through the existing `BOT_PAT` organization secret.

## Policy

- [Public software security policy](public-security.md) — the organization-owner bypass policy replaced on 2026-10-29 and what it applies to.

## Validation toolchain

- [FLOSS source-validation profile](OPENTOFU.md) — the OpenTofu 1.13.1, GitHub provider 6.13.0 and TFLint toolchain used to validate this source.
- [OpenTofu profile advisory assessment — 2026-10-16](OPENTOFU_ADVISORIES.md) — the advisory findings for that OpenTofu build and which operations the assessment covers.
- [Disclosed secure-provider profile](SECURE_PROVIDER.md) — the patched-provider option and why the official 6.13.0 binary keeps its findings.
- [Local-execution TLS transport profile](TLS_PROFILE.md) — the transport key policy for the maintained Terraform configurations and provider calls.

## Evidence

- [Quality evidence and limitations](quality.md) — what the MIT-licensed source and its Python/shell tooling do and do not establish.
- [OpenSSF evidence](openssf-evidence.md) — the source index for reviewing the current badge assessment.
