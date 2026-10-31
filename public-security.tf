variable "public_security_enforcement_repositories" {
  description = "Legacy activation input retained for existing workspace settings. Review policy is mandatory for all active audited public software repositories; private and archived repositories remain excluded."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for repository in var.public_security_enforcement_repositories :
      contains(["ha-desloc", "ha-desloc-card", "ha-echo-dot", "ha-echo-show-5", "rf-airbridge", "slzb-06-recovery"], repository)
    ])
    error_message = "Only repositories in the audited public software scope can opt into review activation."
  }
}

variable "desloc_quota_review_policy_enabled" {
  description = "Use the verified Review policy check instead of native approval counting for public, active ha-desloc only. Enable after its trusted workflow is deployed and verified on a current pull-request head."
  type        = bool
  default     = true
}

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

locals {
  # These review and CI requirements are established policy, not an optional
  # workspace setting. The live public/active guard still applies below.
  mandatory_review_public_software_repositories = local.public_software_repositories

  review_required_public_software_repositories = setintersection(
    local.active_public_software_repositories,
    setunion(
      local.mandatory_review_public_software_repositories,
      var.public_security_enforcement_repositories,
    ),
  )

  # Keep DESLOC in the mandatory protection set: changing the approval mechanism
  # must never restore an administrator bypass or affect another repository.
  desloc_quota_review_policy_active = (
    var.desloc_quota_review_policy_enabled &&
    contains(local.review_required_public_software_repositories, "ha-desloc")
  )
}
