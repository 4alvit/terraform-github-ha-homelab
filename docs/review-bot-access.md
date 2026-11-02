# Review bot access for public projects

The review-policy follow-up in issue #90 uses the existing `BOT_PAT`
organization secret. `public-review-bot-access.tf` manages six individual
repository memberships: ZAC93, the four community tools and Home Studio.
The rollout completed on 2 November 2026: five memberships were added, and
Home Studio's existing association was imported as `BOT_PAT:1414876449`
after checking canonical state ownership. The full selected-repository list
increased from 21 to 26 entries; every prior membership was preserved.
The organization profile already has access and is deliberately excluded.
This resource owns neither the credential value nor its visibility, and does
not replace the existing selected-repository list. It creates no new token,
repository collaborator or bypass actor.

Before a future apply, verify that the existing secret still has `selected` visibility and
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

All six new workflow callers were merged only after actual current-head
`californiantiramisu` approvals and successful validation. Home Studio's existing
approval route was verified separately. The seven existing review rules were
then updated through a separate reviewed HCP plan and read back from GitHub;
each requires one current approval. Membership and rule changes use separate
plans so credential access can be validated before enforcing reviews.

Before and after an approved membership apply, compare the full selected-ID
list: only the reviewed additions may differ. Re-read secret visibility and
the target's inherited secret-name metadata without retrieving its value.
Preserve all other memberships. Removing one of these singleton resources in a
future approved plan removes that repository's access; it does not delete the
organization secret or the repository's collaborator.
