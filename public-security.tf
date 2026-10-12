variable "public_security_enforcement_repositories" {
  description = "Public repositories whose approval automation has been verified and whose stricter review policy is explicitly activated. Existing administrator bypasses remain until activation."
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
  review_required_public_software_repositories = setintersection(
    local.active_public_software_repositories,
    var.public_security_enforcement_repositories,
  )
}
