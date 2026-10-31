# Review bot access for the remaining public projects

The review-policy follow-up in issue #90 uses the existing `BOT_PAT`
organization secret. `public-review-bot-access.tf` proposes six individual
repository memberships: ZAC93, the four community tools and Home Studio.
The organization profile already has access and is deliberately excluded.
This resource owns neither the credential value nor its visibility, and does
not replace the existing selected-repository list. It creates no new token,
repository collaborator or bypass actor.

This is proposed configuration, not evidence of granted access. Before any
apply, verify that the existing secret still has `selected` visibility and
that no other Terraform resource or workspace already owns a target
membership. If a membership has been added meanwhile, investigate and adopt
its existing ownership instead of managing it twice. Keep credentials and raw
state out of plans shared for review; retain only repository IDs, resource
addresses and action summaries.

Install and review the metadata-only approval workflow before granting access.
Pin it to an accepted immutable shared-workflow revision, preserve author and
default-branch checks, and never execute pull-request code with the credential.
After access is granted, verify a real current-head independent approval before
enforcing the native review count. A bot-authored pull request still needs a
different reviewer; the existing human review path does not require creating
another credential.

Home Studio remains on hold until its owner releases the stable-artifact
verification freeze. Do not apply its secret membership, review rule or workflow
changes before that release. Keep the separate first-wave configuration and
apply plan immutable; an unscoped plan containing pending second-wave changes
must not be used for first-wave activation.

Before and after an approved membership apply, compare the full selected-ID
list: only the reviewed additions may differ. Re-read secret visibility and
the target's inherited secret-name metadata without retrieving its value.
Preserve all other memberships. Removing one of these singleton resources in a
future approved plan removes that repository's access; it does not delete the
organization secret or the repository's collaborator.
