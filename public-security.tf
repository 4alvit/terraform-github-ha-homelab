# Public software explicitly audited for the OpenSSF rollout. Private and archived
# repositories are excluded using live visibility before new rules are created.
locals {
  public_software_repositories = toset([
    "ha-desloc",
    "ha-desloc-card",
    "ha-echo-dot",
    "ha-echo-show-5",
    "rf-airbridge",
    "slzb-06-recovery"
  ])
}

data "github_repository" "public_software" {
  for_each  = local.public_software_repositories
  full_name = "ha-homelab/${each.value}"
}

locals {
  active_public_software_repositories = toset([
    for repo, metadata in data.github_repository.public_software : repo
    if metadata.visibility == "public" && !metadata.archived
  ])
}
