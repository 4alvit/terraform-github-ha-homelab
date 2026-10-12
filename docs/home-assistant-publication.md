# Home Assistant source publication

The public configuration starts a new Git history with a reviewed file snapshot.
The previous repository keeps its private visibility, repository ID, branches,
pull requests and workflow records under `home-assistant-private`. The old
`automations` and `scripts` repositories also remain private; their reviewed
current files are bundled into the new public configuration as normal folders.

## Preserve the old repository identity

The existing Terraform address remains
`github_repository.repositories["home-assistant"]`. Its explicit `name` override
renames the remote repository to `home-assistant-private`; do not change its
visibility, remove it from state, or create a replacement. Review the remote plan
before applying. `prevent_destroy` remains in force.

After the rename, update old local clone remotes and dependent tooling to the
private repository URL. Reusing the old name removes GitHub's rename redirect.
Never push an old checkout's branches or tags into the new public repository.

## Publish a new file snapshot

Create the new public repository only after the rename has completed. Keep the
old and new repositories at separate Terraform addresses. The new repository
uses `github_repository.home_assistant_public`. Use an empty new
repository and push only the fresh `main` root commit from a reviewed directory
that never contained the predecessor's Git database. Do not use GitHub import,
forking, mirror pushes, old tags, or a recursive copy of a live HA configuration.

Before publication, scan all root and bundled component files, validate their
contracts, assemble the release without private dependencies and run the runtime
regressions. Public CI must run on GitHub-hosted machines with read-only checkout
permissions, without private runners or deployment credentials.

Set the new default branch and activate its public main-branch rules after the
initial push. Enable secret scanning and push protection when creating the public
repository. Finish with a fresh public clone, one-commit history verification,
source and build checks, successful public CI, and a no-change Terraform plan.

## Recovery

Until the new name has been populated, the private predecessor remains the
source of the existing deployed configuration. Publishing the new source does
not deploy or restart Home Assistant. If publication must stop, retain the old
private repository; do not expose its history to populate the new repository.
Apply any infrastructure reversal through Terraform after checking both remote
repository IDs and the current source of dependent tooling.

## Scope of the migration apply

The initial full plan identified pre-existing differences in other public
repositories' rulesets. Do not apply those removals as part of this migration.
Use explicit targets for the predecessor's repository, default branch,
vulnerability alerts and Dependabot settings, then the separately named public
resources. Review each actual plan and confirm the predecessor keeps the same
GitHub repository ID. A final scoped no-change plan verifies this migration;
any remaining full-workspace drift needs separate review.
