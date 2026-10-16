# Security Policy

Report vulnerabilities privately using [GitHub private reporting](https://github.com/4alvit/terraform-github-ha-homelab/security/advisories/new). Include the affected revision, a redacted reproduction, expected behavior and impact. Do not publish exploit details before coordinating with maintainers.

## Supported versions and response

The maintained default branch is supported. Report the affected commit and the
canonical state/workspace identity, without credentials or state contents.
Maintainers aim to acknowledge vulnerability reports within 14 days and arrange
a coordinated fix and disclosure. Critical issues and active exploitation take
priority. Publicly known medium-or-higher vulnerabilities must be fixed within
60 days of becoming public; confirmation does not restart that clock. Release
notes or the change record identify the fix, affected versions, mitigations and
assigned advisories. Urgent mitigation guidance can precede full disclosure.

## Cryptographic configuration and response

Use the [supported Terraform/provider TLS profile](docs/TLS_PROFILE.md), retaining certificate and hostname verification. Do not work around a failed certificate check using insecure flags. Authenticate with minimum-scope tokens held in private environment or sensitive workspace variables. Never commit a real state, plan, key or credential.

Triage reports by reproducing with synthetic inputs, assessing affected revisions and impact, testing a fix, coordinating disclosure and recording the corrected release. Credit the reporter unless anonymity is requested. There is currently no backup maintainer or tested one-week access recovery arrangement.
